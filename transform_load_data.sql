-- because pages with file types don't contain main page info
INSERT INTO
    simplewikiclean.categorylinks (cl_from, cl_to, cl_timestamp)
SELECT
    c.cl_from,
    c.cl_to,
    c.cl_timestamp
FROM
    simplewiki.categorylinks c
WHERE
    c.cl_type != 'file';

-- to simplify, only considering Main namespace -> real content pages
-- to simplify, dont consider page_is_redirect
-- lang is all null, 
INSERT INTO
    simplewikiclean.page (
        page_id,
        page_title,
        page_is_new,
        page_touched,
        page_links_updated,
        page_latest,
        page_content_model
    )
SELECT
    p.page_id,
    p.page_title,
    p.page_is_new,
    str_to_date(p.page_touched, '%Y%m%d%H%i%s') page_touched,
    str_to_date(p.page_links_updated, '%Y%m%d%H%i%s') page_links_updated,
    p.page_latest,
    p.page_content_model
FROM
    simplewiki.page p
where
    p.page_namespace = 0;

-- add page last modified to page table
UPDATE
    simplewikiclean.page p,
    (
        SELECT
            page_id,
            page_last_modified
        FROM
            simplewikiclean.pagemodification
    ) pm
SET
    p.page_last_modified = pm.page_last_modified
WHERE
    p.page_id = pm.page_id;


INSERT INTO
    simplewikiclean.pagelinksorder (page_id, page_to, page_to_order)
SELECT
    plo.page_id,
    plo.page_to,
    plo.page_to_order
FROM
    simplewiki.pagelinksorder plo;

--  to add ids for mapping
UPDATE
    simplewikiclean.pagelinksorder plo,
    (
        SELECT
            page_id,
            page_title
        FROM
            simplewikiclean.page
    ) p
SET
    plo.page_to_id = p.page_id
WHERE
    plo.page_to = p.page_title;

CREATE
OR REPLACE VIEW simplewikiclean.category AS
SELECT
    c.cl_to,
    count(c.cl_from) num_links
FROM
    simplewikiclean.categorylinks c
WHERE
    c.cl_from IN (
        SELECT
            p.page_id
        FROM
            simplewikiclean.page p
    )
GROUP BY
    c.cl_to;

-- For generating category outdatedness
INSERT INTO
    simplewikiclean.categoryoutdatedness
SELECT
    grouped_data.category,
    grouped_data.page_id,
    grouped_data.newest_page_link,
    page_date.page_last_modified,
    (
        CASE
            WHEN grouped_data.newest_page_link >= page_date.page_last_modified THEN 1
            ELSE 0
        END
    ) is_outdated,
    TIMESTAMPDIFF(
        SECOND,
        page_date.page_last_modified,
        grouped_data.newest_page_link
    ) time_stamp_diff
FROM
    (
        SELECT
            l.cl_to category,
            l.page_id,
            MAX(p.page_last_modified) newest_page_link
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            c.cl_from,
                            c.cl_to
                        FROM
                            simplewikiclean.categorylinks c
                            INNER JOIN (
                                SELECT
                                    cat.cl_to
                                FROM
                                    simplewikiclean.category cat
                                ORDER BY
                                    cat.num_links DESC
                                LIMIT
                                    10
                            ) tc ON c.cl_to = tc.cl_to
                    ) from_ids
                    INNER JOIN (
                        SELECT
                            plo.page_id,
                            plo.page_to_id
                        FROM
                            simplewikiclean.pagelinksorder plo
                        WHERE
                            plo.page_to_id IS NOT NULL
                    ) to_ids ON from_ids.cl_from = to_ids.page_id
            ) l
            LEFT JOIN (
                SELECT
                    p2.page_id,
                    p2.page_last_modified
                FROM
                    simplewikiclean.page p2
            ) p ON l.page_to_id = p.page_id
        group by
            category,
            l.page_id
    ) grouped_data
    LEFT JOIN (
        SELECT
            p3.page_id,
            p3.page_last_modified
        FROM
            simplewikiclean.page p3
    ) page_date ON grouped_data.page_id = page_date.page_id;
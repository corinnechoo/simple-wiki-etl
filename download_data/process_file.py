"""
This script processes the bz2 files and cleans the data before inserting 
it into the database.
"""

import bz2
import datetime
import glob
import os
import re
import xml.etree.ElementTree as ET
from collections import OrderedDict
from multiprocessing import Pool

from ..db import MySQLPool

dbconfig = {
    "host": os.environ['host'],
    "port":  os.environ['port'],
    "user":  os.environ['user'],
    "password":  os.environ['password'],
    "database":  os.environ['database'],
}

mysql = MySQLPool(**dbconfig)


def process_file(file):
    """
    Reads file and calls other functions to process the data in each file.
    With the generated insert SQL statement, it executes the query on the
    database and prints the filename and error message if an error occurs

    Parameters
    ----------
    file : str
        The file location a single bz2 file
    """
    with bz2.open(file, "rb") as f:
        content = f.read()
        try:
            tree = ET.ElementTree(ET.fromstring(content.decode()))
            pagemodified_query, pagelinks_query = parse_pages(tree)
            if pagemodified_query:
                try:
                    mysql.execute(pagemodified_query)
                except Exception as e:
                    print("*****************", file)
                    print(e)
            if pagelinks_query:
                try:
                    mysql.execute(pagelinks_query)
                except Exception as e:
                    print("*****************", file)
                    print(e)

        except Exception as e:
            print("*****************", file)
            print(e)
    return


def parse_pages(tree):
    """
    Processes all the pages in one file to generate the required columns in
    the database. The <ns> tag contains the page namespace, and for this
    project only pages in the main namespace (0) are kept. Function searches
    for page links in the text by looking for text like the expression
    [[Example]] or [[Asteraceae|Daisy]. The date is also formatted to be
    compatible with other dates in the db


    Parameters
    ----------
    tree : xml.etree.ElementTree
          the element tree containing page details
    Returns
    -------
    string
        an insert sql statement
    """
    pagelinks_query = """INSERT INTO pagelinksorder (page_id, page_last_modified, page_to, page_to_order) VALUES"""

    pagemodified_query = """INSERT INTO pagemodification (page_id, page_last_modified) VALUES"""

    for page in tree.findall('.page'):
        namespace = page.find('.ns').text

        if namespace != '0':
            continue

        page_id = page.find('.id').text
        last_update = page.find('.revision/timestamp').text
        last_update_formatted = datetime.datetime.strptime(last_update, '%Y-%m-%dT%H:%M:%SZ').strftime('%Y-%m-%d %H:%M:%S')
        text = page.find('.revision/text').text

        all_links = re.findall(r'\[\[([\w ]+)(?:\||\]\])', text)
        clean_links = (list(map(lambda x: x.replace(" ", "_"), OrderedDict.fromkeys(all_links))))

        single_query = format_pagelinks_query(page_id, clean_links)

        pagelinks_query += single_query
        pagemodified_query += f'({page_id}, "{last_update_formatted}"),'

    #  empty query
    pagemodified_query = pagemodified_query[:-1] + f"ON DUPLICATE KEY UPDATE page_id={page_id}" if pagemodified_query[-1] != ',' else None
    pagelinks_query = pagelinks_query[:-1] + f"ON DUPLICATE KEY UPDATE page_id={page_id}" if pagemodified_query[-1] != ',' else None
    return pagemodified_query, pagelinks_query


def format_pagelinks_query(page_id, links):
    """
    Converts the data into row format to insert into the db

    Parameters
    ----------
    page_id : string
        page id of each page
    page_last_modified: string
        last modified date of the page
    links: list
        ordered list of how the links appear on a page
    Returns
    -------
    string
        a concatenated string of values formatted for a SQL insert statement
    """
    insert_query = ''
    for index, value in enumerate(links):
        insert_query += f'({page_id}, "{value}", {index}),'

    return insert_query


if __name__ == "__main__":
    folder_path = '/code/data/chunks'

    p = Pool(2)
    p.map(process_file, glob.glob(f'{folder_path}/*.bz2'))

    p.close()

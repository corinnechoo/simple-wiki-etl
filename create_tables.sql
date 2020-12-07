CREATE TABLE IF NOT EXISTS simplewikiclean.`categorylinks` (
  `cl_from` int unsigned NOT NULL DEFAULT '0',
  `cl_to` varbinary(255) NOT NULL DEFAULT '',
  `cl_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cl_from`, `cl_to`),
  KEY `cl_timestamp` (`cl_to`, `cl_timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET = binary;

CREATE TABLE IF NOT EXISTS simplewikiclean.`pagelinksorder` (
  `page_id` int unsigned NOT NULL,
  `page_to` varbinary(255) NOT NULL,
  `page_to_order` int NOT NULL DEFAULT 0,
  `page_to_id` int DEFAULT NULL,
  PRIMARY KEY (`page_id`, `page_to`),
  KEY `page_order` (`page_id`, `page_to_id`, `page_to_order`),
) ENGINE = InnoDB AUTO_INCREMENT = 804808 DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS simplewikiclean.`pagemodification` (
  `page_id` int unsigned NOT NULL,
  `page_last_modified` datetime NOT NULL,
  PRIMARY KEY (`page_id`),
  KEY `page_modified` (`page_id`, `page_last_modified`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS simplewikiclean.`page` (
  `page_id` int unsigned NOT NULL AUTO_INCREMENT,
  `page_title` varbinary(255) NOT NULL,
  `page_is_new` tinyint unsigned NOT NULL,
  `page_touched` timestamp NOT NULL,
  `page_links_updated` timestamp DEFAULT NULL,
  `page_last_modified` datetime DEFAULT NULL,
  `page_latest` int unsigned NOT NULL,
  `page_content_model` varbinary(32) DEFAULT NULL,
  PRIMARY KEY (`page_id`),
  UNIQUE KEY (`page_title`)
) ENGINE = InnoDB AUTO_INCREMENT = 804808 DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `categoryoutdatedness` (
  `category` varbinary(255) NOT NULL DEFAULT '',
  `page_id` int unsigned NOT NULL,
  `newest_page_link` datetime DEFAULT NULL,
  `page_last_modified` datetime,
  `is_outdated` int NOT NULL DEFAULT '0',
  `time_stamp_diff` bigint DEFAULT NULL,
  PRIMARY KEY (`category`, `page_id`),
  KEY (`category`, `page_id`, `time_stamp_diff`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
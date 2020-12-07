
mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE categorylinks > categorylinks_archive.sql 
mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE categoryoutdatedness > categoryoutdatedness_archive.sql 
mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE page > page_archive.sql 
mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE categoryoutdatedness > categoryoutdatedness_archive.sql 

mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE < truncate_tables.sql 
zcat data/page.sql.gz | mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE
zcat data/categorylinks.sql.gz | mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE
zcat data/pagelinks.sql.gz | mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE

mysql -u $DB_USER  -h $DB_HOST --port $DB_PORT -p$DB_PASSWORD $DB_DATABASE < create_tables.sql 

#! /bin/sh

# clean directory
rm data/*.xml.bz2

# download data from wiki

src/download_data/download_dump.sh page
src/download_data/download_dump.sh categorylinks
src/download_data/download_dump.sh pages-articles-multistream

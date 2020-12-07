#! /bin/sh

# split xml.bz2 file into smaller files
python3 -m src.download_data.split_bz_file
# proceses each file and inserts data into db
python3 -m src.download_data.process_file
# simple-wiki-etl

To run the pipeline:

Build the docker image: 
```
docker build --tag wiki-etl .
```

Run:

```
docker run --rm --name wikitest -it \
-e host=$DB_HOST \
-e port=$DB_PORT \
-e user=$DB_USER \
-e password=$DB_PASSWORD \
-e database=$DB_NAME \ 
-e folder_path=src/data/chunks \
-v /tmp:/tmp wiki-etl 
```

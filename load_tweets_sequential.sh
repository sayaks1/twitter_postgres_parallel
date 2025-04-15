#!/bin/bash

files=$(find data/*)

# Check if running in CI environment
if [ -n "$CI" ]; then
  # CI environment settings
  NORMALIZED_DB="postgresql://postgres:pass@localhost:1056/pg_normalized"
  DENORMALIZED_HOST="localhost"
  DENORMALIZED_PORT="1055"
  DENORMALIZED_DB="pg_denormalized"
else
  # Local environment settings
  NORMALIZED_DB="postgresql://postgres:pass@localhost:1056/pg_normalized"
  DENORMALIZED_HOST="localhost"
  DENORMALIZED_PORT="1055"
  DENORMALIZED_DB="pg_denormalized"
fi

echo '================================================================================'
echo 'load denormalized'
echo '================================================================================'
time for file in $files; do
    echo
    # copy your solution to the twitter_postgres assignment here
    export PGPASSWORD=pass
    unzip -p "$file" | sed 's/\\u0000//g' | psql \
        -h "$DENORMALIZED_HOST" -p "$DENORMALIZED_PORT" -U postgres -d "$DENORMALIZED_DB" \
        -c "\copy tweets_jsonb (data) FROM STDIN WITH (FORMAT csv, DELIMITER E'\t', QUOTE E'\b')"
done

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time for file in $files; do
    python3 load_tweets.py --db "$NORMALIZED_DB" --inputs "$file" 
    # copy your solution to the twitter_postgres assignment here
done

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets_batch.py --db=postgresql://postgres:pass@localhost:1057/ --inputs $file
done

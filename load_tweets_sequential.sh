#!/bin/bash

files=$(find data/*)

# Check if running in CI environment
if [ -n "$CI" ]; then
  # CI environment settings
  NORMALIZED_DB="postgresql://postgres:pass@localhost:1056"
  DENORMALIZED_HOST="localhost"
  DENORMALIZED_PORT="1055"
  DENORMALIZED_DB="pg_denormalized"
else
  # Local environment settings
  NORMALIZED_DB="postgresql://postgres:pass@localhost:1056"
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
    unzip -p "$file" | sed 's/\\u0000//g' | psql \
         postgresql://postgres:pass@localhost:1055/postgres \
        -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';" 
done

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time for file in $files; do
    python3 load_tweets.py --db=postgresql://postgres:pass@localhost:1056 --inputs "$file" 
    # copy your solution to the twitter_postgres assignment here
done

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets_batch.py --db=postgresql://postgres:pass@localhost:1057/ --inputs $file
done

#!/bin/sh
file="$1"

python3 load_tweets.py --db=postgresql://postgres:pass@localhost:1056 --inputs "$file"

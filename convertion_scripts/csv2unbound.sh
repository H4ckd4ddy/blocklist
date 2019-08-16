#!/bin/bash

INPUT="blocklist.csv"
OUTPUT="outputs/blocklist.conf"

cp $INPUT $OUTPUT

sed -i '1d' $OUTPUT

sed -i 's/;/ A 0\.0\.0\.0\"###/' $OUTPUT

sed -i 's/;/###/g' $OUTPUT

sed -i 's/^/local-data: \"/' $OUTPUT

echo 'Unbound conf file generated'

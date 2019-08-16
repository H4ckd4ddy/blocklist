#!/bin/bash

INPUT="blocklist.csv"
OUTPUT="outputs/blocklist.txt"

cp $INPUT $OUTPUT
sed -i '1d' $OUTPUT

sed -i 's/;.*//' $OUTPUT

echo 'TXT domains list generated'

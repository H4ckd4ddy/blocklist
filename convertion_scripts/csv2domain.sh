#!/bin/bash

INPUT="blocklist.csv"
OUTPUT="outputs/blocklist.txt"

# Copy source to destination
cp $INPUT $OUTPUT

# Remove first line (csv header)
sed -i '1d' $OUTPUT

# Remove whitelisted lines
sed -i '/;WHITELISTED;/d' $OUTPUT

# Remove all after first ';'
sed -i 's/;.*//' $OUTPUT

echo 'TXT domains list generated'

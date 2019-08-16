#!/bin/bash

echo 'domain;comment;date' > blocklist.csv
cat blocklist.conf >> blocklist.csv

sed -i '/^#/ d' blocklist.csv

sed -i 's/local-data: "//g' blocklist.csv
sed -i 's/ A 0.0.0.0"//g' blocklist.csv
sed -i 's/###/;/g' blocklist.csv

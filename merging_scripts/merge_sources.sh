#!/bin/bash

blocklist="blocklist.csv"
sources="sources.txt"

source_number=0

while IFS= read -r source
do
  # ----- Increment source count -----
  source_number=$(($source_number+1))

  # ----- Check if a hash is present, and split it from URL -----
  array=(${source//;/ })
  source=${array[0]}
  hash=${array[1]}

  # ----- Download blocklist and check -----
  curl --silent -o current.list "$source" > /dev/null
  if [ $? -ne 0 ];then
    echo "Error unreachable : skip $source"
    continue
  fi
  status_code=$(curl --write-out %{http_code} --silent --output /dev/null "$source")
  if [ $status_code -ne 200 ];then
    echo "Error HTTP code $status_code : skip $source"
    continue
  fi

  # ----- Check hash of file, skip if no change -----
  new_hash=($(shasum current.list))
  if [ "$new_hash" = "$hash" ] ;then
    echo "No change, skip"
    continue
  fi

  # ----- Convert DOS EoL to Unix EoL -----
  sed -i 's/\r//' current.list

  # ----- Remove IP -----
  sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\} //' current.list

  # ----- Remove space -----
  sed -i 's/ //' current.list

  # ----- Remove comment after line -----
  sed -i 's/#.*//' current.list

  # ----- Remove tabs -----
  sed -i 's/\t//g' current.list

  # ----- Remove dot at begin of line -----
  sed -i 's/^\.//' current.list

  # ----- Parse blocklist and merge new domain -----
  echo "Start merging $source"
  list="current.list"
  line_count=$(wc -l < current.list)
  current_line=1
  while IFS= read -r domain
  do
    # skip empty line and comment
    if [ -z "$domain" ] || [[ $domain =~ ^# ]] ;then
      continue
    fi
    # check if domain already exist
    match_count=$(grep -c -- "$domain" $blocklist)
    if [ $match_count -eq 0 ];then
      current_date=$(date --iso-8601=seconds)
      echo "Adding $domain"
      echo "$domain;BLACKLISTED;Merged from $source;$current_date" >> $blocklist
    fi
    #echo "[$current_line/$line_count]"
    current_line=$(($current_line+1))
  done < "$list"
  
  # ----- Update list hash -----
  sed -i "$source_number"'s,.*,'"$source"';'"$new_hash"',' sources.txt

done < "$sources"

rm current.list

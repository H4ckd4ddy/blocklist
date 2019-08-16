#!/bin/bash

sources="sources.txt"

source_number=1

while IFS= read -r source
do
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
    match_count=$(grep -c -- "$domain" adslist)
    if [ $match_count -eq 0 ];then
      current_date=$(date --iso-8601=seconds)
      echo "Adding $domain"
      echo "local-data: \"$domain A 0.0.0.0\"###Merged from $source###$current_date" >> adslist
    fi
    #echo "[$current_line/$line_count]"
    current_line=$(($current_line+1))
  done < "$list"

  # ----- Update list hash -----
  sed -i "$source_number"'s,.*,'"$source"';'"$new_hash"',' sources.txt

  rm current.list
  source_number=$(($source_number+1))
   
done < "$sources"

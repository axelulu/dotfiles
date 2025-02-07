#!/bin/bash

read -p "Enter the directory containing the files: " target_dir

if [ ! -d "$target_dir" ]; then
  echo "Directory not found: $target_dir"
  exit 1
fi

read -p "Enter the string to be replaced: " old_string
read -p "Enter the replacement string: " new_string

for file in "$target_dir"/*"$old_string"*; do
  if [[ -f "$file" ]]; then
    new_name=$(echo "$file" | sed "s/$old_string/$new_string/")
    mv "$file" "$new_name"
    echo "Renamed $file to $new_name"
  fi
done


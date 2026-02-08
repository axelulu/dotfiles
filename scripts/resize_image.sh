#!/bin/bash

read -p "Enter the source image file path: " image_file
if [ ! -f "$image_file" ]; then
  echo "File not found: $image_file"
  exit 1
fi

read -p "Enter the destination directory: " dest_dir
if [ ! -d "$dest_dir" ]; then
  echo "Directory not found: $dest_dir"
  exit 1
fi

read -p "Enter the destination file base name: " base_name

read -p "Enter the sizes (comma-separated, e.g., 16,32,64,128,256,512,1024): " sizes_input

IFS=',' read -ra sizes <<< "$sizes_input"

for size in "${sizes[@]}"; do
  size=$(echo "$size" | xargs)  # Trim any leading/trailing whitespace
  if [[ ! "$size" =~ ^[0-9]+$ ]]; then
    echo "Invalid size: $size. Sizes must be numeric."
    continue
  fi
  convert "$image_file" -resize "${size}x${size}" "${dest_dir}/${base_name}_${size}x${size}.png"
  echo "Created ${dest_dir}/${base_name}_${size}x${size}.png"
done

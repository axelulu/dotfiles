#!/bin/zsh

# Function to print messages with color
function print_colored() {
  local color=$1
  local symbol=$2
  local message=$3
  case $color in
    green) echo -e "\033[0;32m$symbol\033[0m $message" ;;
    red) echo -e "\033[0;31m$symbol\033[0m $message" ;;
    *) echo "$message" ;;
  esac
}

# Default to the directory from which the script is run
default_directory=$(pwd)

# Prompt for the directory, default to the directory from which the script is run
read "directory?Enter the directory (default is $default_directory): "
directory=${directory:-$default_directory}

# Prompt for the quality (e.g., 85 for JPEG)
read "quality?Enter the quality (1-100, default is 85): "
quality=${quality:-85}

# Prompt for the maximum length of the long side
read "max_length?Enter the maximum length of the long side (e.g., 800): "

# Prompt for the output file type with default as jpeg
read "output_type?Enter the output file type (png, jpeg, webp, default is jpeg): "
output_type=${output_type:-jpeg}

# Normalize and validate the output file type
case "${output_type,,}" in
  jpg|jpeg) output_type="jpeg" ;;
  png) output_type="png" ;;
  webp) output_type="webp" ;;
  *)
    echo "Invalid output file type. Defaulting to jpeg."
    output_type="jpeg"
    ;;
esac

# Prompt for the output directory name
read "output_dir?Enter the output directory name (default is 'output'): "
output_dir=${output_dir:-output}
output_dir_path="$directory/$output_dir"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir_path"

# Prompt for the name suffix
read "suffix?Enter the name suffix (default is no suffix): "

# Initialize image counter
image_count=1

# Process each image in the directory
for img in "$directory"/*.(jpg|jpeg|png); do
  # Skip if no images are found
  [ -e "$img" ] || continue

  # Determine output name based on suffix and image count
  if [ -n "$suffix" ]; then
    output_name="${suffix}_${image_count}.$output_type"
  else
    base_name=$(basename "$img")
    base_name="${base_name%.*}"
    output_name="${base_name}.$output_type"
  fi

  # Convert and resize the image using `magick`
  if magick "$img" -resize "${max_length}x${max_length}>" -quality "$quality" "$output_dir_path/$output_name" 2>/dev/null; then
    print_colored green "✔" "Processed $img --> $output_dir_path/$output_name"
  else
    print_colored red "✖" "Failed to process $img"
  fi

  # Increment the image counter
  ((image_count++))
done

echo "Image processing complete."

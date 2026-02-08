#!/bin/zsh

# Prompt for a directory
echo "Enter the directory path (leave blank to use the current directory):"
read directory

# Use the current directory if no input is provided
if [ -z "$directory" ]; then
    directory="."
fi

# Change to the specified directory
cd "$directory" || { echo "Directory not found! Exiting."; exit 1; }

# Convert all MOV files to MP4
for file in *.[mM][oO][vV]; do
    # Get the file name without the extension
    filename="${file%.*}"
    # Print the name of the file being converted
    echo "Converting '$file' to '${filename}.mp4'..."
    # Convert to mp4
    ffmpeg -i "$file" -vcodec h264 -acodec aac "${filename}.mp4"
    # Print a completion message
    echo "Finished converting '$file'."
done

echo "All conversions complete

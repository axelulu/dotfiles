#!/usr/bin/env zsh

# Enable nullglob to handle no matches gracefully
setopt null_glob

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Helper functions for formatted output
log_info() {
    echo -e "${BLUE}ℹ${NC} ${BOLD}$1${NC}"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_processing() {
    echo -e "${BLUE}⚙${NC} $1"
}

# Progress separator
print_separator() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to check dependencies
check_dependencies() {
    local dependencies=("magick" "lsd")  # List your dependencies here
    local missing=()

    for dependency in "${dependencies[@]}"; do
        log_info "Checking for $dependency..."
        if ! command -v $dependency &> /dev/null; then
            log_error "$dependency not found."
            missing+=($dependency)
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        log_error "The following dependencies are missing: ${missing[@]}"
        read "INSTALL?Would you like to install them automatically using Homebrew? (y/n): "
        
        if [[ "$INSTALL" == "y" || "$INSTALL" == "Y" ]]; then
            for package in "${missing[@]}"; do
                log_info "Installing $package..."
                brew install $package || { log_error "Failed to install $package"; exit 1; }
            done
        else
            log_error "Please install the missing dependencies manually and re-run the script."
            exit 1
        fi
    fi
}

# Check for Homebrew
log_info "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    log_error "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Check for dependencies
check_dependencies

# Prompt for the source directory, default to the current directory
read "SOURCE_DIR?Enter the source directory (default: current directory): "
SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
SOURCE_DIR_NAME=$(basename "$SOURCE_DIR")
log_info "Source directory set to: $SOURCE_DIR"

# Prompt for quality settings
read "QUALITY?Enter the quality for processed images (default: 70): "
QUALITY="${QUALITY:-70}"
if ! [[ "$QUALITY" =~ ^[0-9]+$ ]] || [ "$QUALITY" -lt 1 ] || [ "$QUALITY" -gt 100 ]; then
    log_error "Quality must be a number between 1 and 100"
    exit 1
fi
log_info "Image quality set to: $QUALITY"

read "BLUR_QUALITY?Enter the quality for blurred images (default: 10): "
BLUR_QUALITY="${BLUR_QUALITY:-10}"
log_info "Blur quality set to: $BLUR_QUALITY"

# Check for images in the root of the source directory
log_info "Searching for images in $SOURCE_DIR"
IMAGE_COUNT=$(find "$SOURCE_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) | wc -l)
log_info "Found $IMAGE_COUNT images."

if [ "$IMAGE_COUNT" -eq 0 ]; then
    log_error "No JPEG images found in the root of $SOURCE_DIR."
    exit 1
fi

# Confirm with the user
while true; do
    read "CONFIRM?Found $IMAGE_COUNT images in $SOURCE_DIR. Do you want to process these images? (y/n): "
    echo "User confirmation: $CONFIRM"
    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        break
    elif [[ "$CONFIRM" == "n" || "$CONFIRM" == "N" ]]; then
        log_info "Image processing aborted."
        exit 0
    else
        log_error "Invalid input. Please enter 'y' for yes or 'n' for no."
    fi
done

# Output directories
OUTPUT_DIRS=("blur" "small" "medium" "large" "xl")

# Create output directories if they don't exist
log_info "Creating output directories..."
for dir in "${OUTPUT_DIRS[@]}"; do
    mkdir -p "$SOURCE_DIR/$dir" || { log_error "Failed to create directory $SOURCE_DIR/$dir"; exit 1; }
done

# Size settings
typeset -A SIZES
SIZES=(small 600 medium 1200 large 1800 xl 2400 blur 600)

# Function to get the next sequence number for a given size
get_next_sequence_number() {
    local size_dir="$1"
    local size="$2"
    local max_number=0
    
    >&2 echo "Checking existing files in $size_dir for size $size..."
    
    for file in "$size_dir"/${SOURCE_DIR_NAME}_*_*.jpeg; do
        if [[ -f "$file" ]]; then
            >&2 echo "Found existing file: $file"
            local number=$(basename "$file" | sed -E "s/${SOURCE_DIR_NAME}_([0-9]+)_.*/\1/")
            if [[ -n "$number" && "$number" =~ ^[0-9]+$ ]]; then
                if (( number > max_number )); then
                    max_number=$number
                fi
            fi
        fi
    done
    
    local next_number=$((max_number + 1))
    >&2 echo "Next sequence number for size $size is $next_number"
    
    echo $next_number
}

# Function to process images
process_image() {
    local image="$1"
    log_processing "Processing image: $image"

    # Convert to absolute path if needed
    [[ "$image" != /* ]] && image="$(pwd)/$image"

    for size in "${(@k)SIZES}"; do
        local dimension=${SIZES[$size]}
        local size_dir="$SOURCE_DIR/$size"
        local sequence_number=$(get_next_sequence_number "$size_dir" "$dimension")
        
        # Create full paths for output files
        local output_jpeg="$size_dir/${SOURCE_DIR_NAME}_${sequence_number}_${dimension}.jpeg"
        local output_webp="$size_dir/${SOURCE_DIR_NAME}_${sequence_number}_${dimension}.webp"
        
        log_processing "Processing $image for size $size ($dimension)"
        if [[ "$size" == "blur" ]]; then
            magick "$image" \
                -resize "${dimension}x${dimension}>" \
                -quality $BLUR_QUALITY \
                "$output_jpeg" || { log_error "Failed to process $image for blur size"; exit 1; }
        else
            magick "$image" \
                -resize "${dimension}x${dimension}>" \
                -quality $QUALITY \
                "$output_jpeg" || { log_error "Failed to process $image for size $size (JPEG)"; exit 1; }
            
            magick "$image" \
                -resize "${dimension}x${dimension}>" \
                -quality $QUALITY \
                "$output_webp" || { log_error "Failed to process $image for size $size (WEBP)"; exit 1; }
        fi

        log_success "Processed $image to $output_jpeg and $output_webp"
    done
}

# Loop through all jpg files in the source directory
log_info "Starting image processing loop..."
for image in "$SOURCE_DIR"/*.(jpg|jpeg); do
    # Check if file exists (to handle glob if no files found)
    if [[ -e "$image" ]]; then
        process_image "$image"
    else
        log_error "No images found to process."
    fi
done

log_success "All images have been processed."

# Display the directory tree using lsd
log_info "Displaying directory structure:"
lsd --tree --depth 2 "$SOURCE_DIR"

# Add error handling for directory access
if [ ! -d "$SOURCE_DIR" ] || [ ! -r "$SOURCE_DIR" ]; then
    log_error "Error: Cannot access directory $SOURCE_DIR"
    exit 1
fi

# Near the start of the script, convert SOURCE_DIR to absolute path
SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
[[ "$SOURCE_DIR" != /* ]] && SOURCE_DIR="$(pwd)/$SOURCE_DIR"

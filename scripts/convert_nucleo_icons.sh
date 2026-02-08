#!/bin/bash

# Path to your files
INPUT_FILE="$HOME/Dev/craftwork-rails/app/javascript/components/nucleo-icons/icons.json"
OUTPUT_FILE="$HOME/Dev/craftwork-rails/app/javascript/components/nucleo-icons/icons.new.2.tsx"

# Create the TSX file with the header, types, and components
cat > "$OUTPUT_FILE" << 'EOL'
interface SVGProps {
  size?: number;
  className?: string;
}

const SVGComponent: React.FC<SVGProps & { children: React.ReactNode }> = ({ 
  size = 18, 
  className = "", 
  children 
}) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 18 18"
    style={{ width: size, height: size }}
    className={className}
  >
    {children}
  </svg>
);

export const NucleoIcons = {
EOL

# Process the JSON file and append to TSX
jq -r '.icons[] | .name as $name | 
  "  " + ($name | 
    gsub("-2"; "Two") |
    gsub("-(?<a>[a-z0-9])"; (.a | ascii_upcase)) | 
    gsub("^(?<a>[a-z])"; (.a | ascii_upcase))
  ) + ": ({ size, className }: SVGProps) => (\n    <SVGComponent size={size} className={className}>" + 
  (.content | 
   sub("<svg[^>]*>"; "") | 
   sub("</svg>$"; "") |
   sub("class=\"nc-icon-wrapper\""; "") |
   gsub("stroke-linecap"; "strokeLinecap") |
   gsub("stroke-linejoin"; "strokeLinejoin") |
   gsub("data-color"; "data-color") |  # Changed from dataColor to data-color
   gsub("stroke-width"; "strokeWidth") |
   gsub("fill-rule"; "fillRule") |
   gsub("clip-rule"; "clipRule")
  ) + 
  "</SVGComponent>\n  ),"' "$INPUT_FILE" >> "$OUTPUT_FILE"

# Add the closing bracket
echo "};" >> "$OUTPUT_FILE"

# Clean up the file
# Remove the last comma before the closing bracket
sed -i '' -e '$!N;s/,\n}/\n}/' "$OUTPUT_FILE"

echo "Conversion complete! Check $OUTPUT_FILE"

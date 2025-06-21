# Exit on error
set -e

# Parse options
SKIP_PDF=false
while getopts "d" opt; do
    case $opt in
        d)
            SKIP_PDF=true
            ;;
        *)
            echo "Usage: $0 [-d]"
            exit 1
            ;;
    esac
done

# Check for required arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 [-d] INPUT_FILE OUTPUT_DIR"
    exit 1
fi

# Shift processed options
shift $((OPTIND - 1))

INPUT_FILE="$1"
OUTPUT_DIR="$2"

# Get base name without extension for output files
BASE_NAME=$(basename "$INPUT_FILE" .md)

# Ensure required packages are installed
echo "Installing necessary packages..."
if ! command -v pandoc &> /dev/null; then
    echo "Pandoc not found. Installing..."
    nix-env -iA nixos.pandoc
fi

if ! command -v xelatex &> /dev/null; then
    echo "XeLaTeX not found. Installing TexLive..."
    nix-env -iA nixos.texlive.combined.scheme-full
fi

# Define paths
METADATA_DIR="latex"
COMPILED_MD="${OUTPUT_DIR}/compiled_${BASE_NAME}.md"
TEX_OUTPUT="${OUTPUT_DIR}/${BASE_NAME}.tex"
PDF_OUTPUT="${OUTPUT_DIR}/${BASE_NAME}.pdf"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Step 1: Preprocess Markdown to include referenced files and embedded content
echo "Preprocessing Markdown to include referenced files and embedded content..."

# Function to recursively process and expand Markdown references
process_markdown() {
    local input_file="$1"
    local output_file="$2"

    # Create a temporary file to store processed content
    local tmp_file=$(mktemp)

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ \[.*?\]\((.*?\.md)\) ]]; then
            # Extract referenced file path
            ref_file="${BASH_REMATCH[1]}"
            if [ -f "$ref_file" ]; then
                echo "Including content from $ref_file..."
                echo "" >> "$tmp_file"
                echo "" >> "$tmp_file"
                # Process the referenced file recursively
                process_markdown "$ref_file" "$tmp_file"
                echo "" >> "$tmp_file"
            else
                echo "Warning: Referenced file '$ref_file' not found. Skipping..."
                echo "$line" >> "$tmp_file"
            fi
        elif [[ "$line" =~ \[.*?\]\((http.*?|https.*?)\) ]]; then
            # External URL references remain unchanged
            echo "$line" >> "$tmp_file"
        else
            # Copy regular lines
            echo "$line" >> "$tmp_file"
        fi
    done < "$input_file"

    # Append processed content to the output file
    cat "$tmp_file" >> "$output_file"
    rm "$tmp_file"
}

# Start processing the main input file
> "$COMPILED_MD" # Empty the output file
process_markdown "$INPUT_FILE" "$COMPILED_MD"

# Step 2: Generate LaTeX file using Pandoc
echo "Generating LaTeX document..."

pandoc \
    --from gfm \
    --to latex \
    --output "$TEX_OUTPUT" \
    --include-in-header "${METADATA_DIR}/Preamble.tex" \
    --include-in-header "${METADATA_DIR}/Portada.tex" \
    --resource-path=".:img:market_research:technical_research:latex" \
    --metadata-file "${METADATA_DIR}/metadata.yaml" \
    --lua-filter "${METADATA_DIR}/chapter-filter.lua" \
    --toc \
    --toc-depth=2 \
    --number-sections \
    --quiet \
    --fail-if-warnings=false \
    "$COMPILED_MD"

# Step 3: Compile the LaTeX file to PDF

if [ "$SKIP_PDF" = false ]; then
    echo "Compiling PDF..."
    xelatex -output-directory="$OUTPUT_DIR" "$TEX_OUTPUT"
    echo "PDF generated successfully: $PDF_OUTPUT"
else
    echo "Skipping PDF generation as per user request."
    echo "Generated LaTeX file: $TEX_OUTPUT"
    echo "You can compile it to PDF manually using: xelatex -output-directory=$OUTPUT_DIR $TEX_OUTPUT"
fi

echo "Documentation build completed successfully."

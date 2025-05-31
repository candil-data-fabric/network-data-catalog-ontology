#/bin/bash

# Directory paths
ONTOLOGY_DIR="ontology"
DOCS_DIR="docs"
DIAGRAMS_DIR="diagrams"

# Loop through each .drawio file in the diagrams directory
for file in "$DIAGRAMS_DIR"/*.drawio; do
    # Check if the file exists (in case there are no .ttl files)
    if [ -f "$file" ]; then
        # Export drawio diagrams in SVG and PNG format
        # TODO: Export using drawio-export container
        module_name="$(basename "$file" .drawio)"
        /Applications/draw.io.app/Contents/MacOS/draw.io --export --format png --output "$DIAGRAMS_DIR"/$module_name.png "$DIAGRAMS_DIR"/$module_name.drawio
        /Applications/draw.io.app/Contents/MacOS/draw.io --export --format svg --output "$DIAGRAMS_DIR"/$module_name.svg "$DIAGRAMS_DIR"/$module_name.drawio
    fi
done

# Check if the docs directory exists, create if not
mkdir -p "$DOCS_DIR"

# Loop through each .ttl file in the ontology directory
for file in "$ONTOLOGY_DIR"/*.ttl; do
    # Check if the file exists (in case there are no .ttl files)
    if [ -f "$file" ]; then
        # Extract the module ename (without path or extension)
        module_name="$(basename "$file" .ttl)"
        # Generate WIDOCO documentation using Docker
        docker run -ti --rm \
          -v `pwd`/ontology:/usr/local/widoco/in \
          -v `pwd`/docs/$module_name:/usr/local/widoco/out \
          ghcr.io/dgarijo/widoco:v1.4.25 -ontFile in/$module_name.ttl \
          -outFolder out -webVowl -oops  -getOntologyMetadata \
          -excludeIntroduction -htaccess -licensius -noPlaceHolderText

        # Use Git to checkout abstract and description sections in the document
        #git checkout docs/$module_name/sections/description-en.html

        # Copy ontology diagram into resources module
        mkdir docs/$module_name/resources/images
        cp diagrams/$module_name.png docs/$module_name/resources/images/

        # Rename index html file
        mv docs/$module_name/index-en.html docs/$module_name/index.html
    fi
done

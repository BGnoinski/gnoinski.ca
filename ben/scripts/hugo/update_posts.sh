#!/bin/bash
sed -i 's|Title:|---\ntitle:|g' $1
sed -i 's|Date:|date:|g' $1
sed -i 's|Category:|categories:\n  -|g' $1
sed -i 's|Tags:|tags:\n  -|g' $1
sed -i '8i---' $1
sed -i '7 s|,|\n  -|g' $1
sed -i '5 s|,|\n  -|g' $1
sed -i 's|> \*\*|>\*\*|g' $1
sed -i 's|\*\* <|\*\*<|g' $1

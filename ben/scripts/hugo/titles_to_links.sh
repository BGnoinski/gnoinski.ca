#!/bin/bash
sed -i 's| - |-|g' titles.txt
sed -i 's|,||g' titles.txt
sed -i 's| |-|g' titles.txt
# https://stackoverflow.com/questions/9591744/how-to-add-to-the-end-of-lines-containing-a-pattern-with-sed-or-awk
sed -i '/-/ s/$/.html/' titles.txt
# https://unix.stackexchange.com/questions/171603/convert-file-contents-to-lower-case
tr '[:upper:]' '[:lower:]' < titles.txt > titles_lowercase.txt
mv titles_lowercase.txt titles.txt

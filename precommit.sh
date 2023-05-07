#!/bin/bash

# Function to check coding style using astyle
check_style() {
    local file="$1"
    local style_options="--style=google --convert-tabs --indent=spaces=2 --indent-switches --indent-preproc-block --indent-preproc-define --indent-col1-comments --break-blocks --delete-empty-lines --align-pointer=name --max-code-length=200 --break-after-logical --lineend=linux"
    astyle $style_options "$file" || exit 1
}

# Find all C# (.cs), C++ (.cpp, .hpp), and Java (.java) files in the repository
files=$(git diff --name-only --cached --diff-filter=ACMRTUXB | grep -E '\.(cs|cpp|hpp|java)$')

# Check coding style for each file
for file in $files; do
    check_style "$file"
done

exit 0

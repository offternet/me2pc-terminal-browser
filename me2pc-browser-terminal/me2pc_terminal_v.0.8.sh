#!/bin/bash
# "me2pc html Browser Terminal" (c) Robert J. Cooper - All rights reserved>
# COPYRIGHT NOTICE The MIT License (MIT)Copyright © 2025 | copyright holder:
# Robert J. Cooper, Kingman, AZ, USA>
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# 3FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.>

# VER: 0.8  07/09/2025

unset file
unset filename
unset timeout
unset search_dir
unset start_time
unset varname
unset content
unset runCommand

sleep 1

	# Directory to search: CHANGE LAST directory: to the directory you want to listen for files and where files are created.
	search_dir="/home/$USER/Downloads"

	# Check for me2pc_backups directory. If not exist, create it. search_dir="/path/to/your/directory"  
	if [ ! -d "$search_dir/me2pc_backups" ]; then
	mkdir -p "$search_dir/me2pc_backups"
	fi

	# Timeout duration in seconds
	timeout=180
	start_time=$(date +%s)

   # Find all .me2pc files and process them
   while true; do
    found_files=0
    
   while IFS= read -r -d '' file; do
        found_files=1
        
   	# Get the filename without path and extension
   	export filename=$(basename "$file" .me2pc)

	# Replace any invalid characters in variable names
	varname=$(echo "$filename" | sed 's/[^a-zA-Z0-9_]/_/g')

	# Ver 3. Read whole file and preserve last new line TESTED WITH ERROR Whole file is on one line.
	content=$(sed -n 'p' "$file")

	# Replace any * character with a space in content
	content=${content//\*/ }
	declare -g "$varname"="$content"
	export "$varname"
        
        # Ver 1 works for single line code: Read file content line 1 only and only data then assign to variable
        # content=$(sed -n '1{p;q;}' "$file" | tr -d '\n')

	# Ver 2Read whole file and preserve last new line TESTED WITH ERROR Whole file is on one line.
	# content=$(sed -n 'p' "$file" | tr -d '\n')

        # Optional: print the variable name and first few characters for verification
        echo "Created and exported variable: \$$varname (content starts with: ${!varname:0:20}...)"

        # Create file.contents with the actual variable content (not just the name)
        echo "${!varname}" > "$file.contents"

        # Set runCommand to the contents of the .contents file
        runCommand=$(<"$file.contents")
        export runCommand

    done < <(find "$search_dir" -type f -name "*.me2pc" -print0)

    # If we found files, break out of the loop
    if [ $found_files -eq 1 ]; then
        break
    fi
    
    # Check if timeout has been reached
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    if [ $elapsed -ge $timeout ]; then
        echo "Timeout reached after $timeout seconds. No .me2pc files found."
        exit 1
    fi
    
    # Wait for 1 second before checking again
  
done



echo "$runCommand"

# No stop read AppWindow popup
gnome-terminal --title="$content" -- bash -c "$runCommand; exit"

# Add stop read command in every popup terminal window 
#gnome-terminal --title="$filename" -- bash -c "$runCommand;  read -n 1 -s -r -p 'Press any key to exit'; exit"


rm $search_dir/*.me2pc
rm $search_dir/*.contents

# No stop read command in me2pc popup execution
# PUT THIS IN Required stop and read *.me2pc command file like apt_get_update: read -p 'Press any key to exit'

# Add stop read command in every me2pc popup execution
# read -p 'Press any key to exit'

######## Make rotate on off process ./search-60secs-dwnloads.sh

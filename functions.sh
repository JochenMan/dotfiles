#!/bin/sh

todoDirname="$HOME/todos"
todoFilename="$todoDirname/todos.md"

noteDirname="$HOME/notes"
noteFilename="$noteDirname/note-$(date +%Y-%m-%d).md"

# Function to swap Caps Lock and Ctrl
swap_caps_ctrl() {
    current_option=$(setxkbmap -query | grep options | awk '{print $2}')

    if [[ $current_option == *"ctrl:swapcaps"* ]]; then
        echo "Reverting Caps Lock and Ctrl to default settings."
        setxkbmap -option
    else
        echo "Swapping Caps Lock and Ctrl."
        setxkbmap -option ctrl:swapcaps
    fi
}

td() {
  # todoer function that appends a new todo to a list of todos
  if [ ! -d $todoDirname ]; then
    mkdir -p $todoDirname
  fi

  if [ ! -f $todoFilename ]; then
    echo "# Todos" > $todoFilename
  fi

  vim -c "norm Go" \
    -c "norm Go- [ ]$(date +%y%m%d)  " \
    -c "norm A" \
    -c "norm zz" \
    -c "startinsert" $todoFilename
}

nt() {
  # notetaking function that creates one note file per day
  if [ ! -d $noteDirname ]; then
    mkdir -p $noteDirname
  fi

  if [ ! -f $noteFilename ]; then
    echo "# Notes for $(date +%Y-%m-%d)" > $noteFilename
  fi

  vim -c "norm Go" \
    -c "norm Go## $(date +"%r")" \
    -c "norm G2o" \
    -c "norm zz" \
    -c "startinsert" $noteFilename
}

ntc() {
  # cats all notes together into allNotes.md file and opens it
  cat $noteDirname/note-*.md > $noteDirname/allNotes.md
  vim $noteDirname/allNotes.md
}

ns() {
  local tagName=$1

  # Check if a tag was provided
  if [ -z "$tagName" ]; then
    echo "Usage: ns <string>"
    return 1
  fi

  # Header for search results
  echo "# Search Results for $tagName"
  echo "Compiled on $(date)"
  echo "-----------------------------"

  # Search through notes and output matching file contents
  grep -lri --exclude='searchResults.md' --exclude='allNotes.md' "$tagName" "$noteDirname" | while read -r filename; do
    echo "## From $filename"
    cat "$filename"
    echo "-----------------------------"
  done
}

nsc() {
  # Search Tag function searches for a tag in all notes and compiles matching notes into searchResults.md
  local tagName=$1
  local searchResults="$noteDirname/searchResults.md"

  # Check if a tag was provided
  if [ -z "$tagName" ]; then
    echo "Usage: nsc <string>"
    return 1
  fi

  # Prepare the search results file
  echo "# Search Results for $tagName" > $searchResults
  echo "Compiled on $(date)" >> $searchResults
  echo "-----------------------------" >> $searchResults

  # Search through notes, exclude searchResults.md, and append matching files' contents to searchResults.md
  grep -lir --exclude='searchResults.md' "$tagName" $noteDirname | while read filename; do
    echo "## From $filename" >> $searchResults
    cat "$filename" >> $searchResults
    echo "-----------------------------" >> $searchResults
  done

  # Open the search results in vim
  vim $searchResults
}


nse() {
  local searchString=$1
  local noteDirname="$noteDirname"

  # Check if a search string was provided
  if [ -z "$searchString" ]; then
    echo "Usage: nse <string>"
    return 1
  fi

  # Prepare the Vim command to open each matching file in a new tab
  local vimCommand="vim -p"
  local matchCount=0

  # Append each matching file to the Vim command
  while IFS= read -r file; do
    vimCommand+=" \"$file\""
    ((matchCount++))
  done < <(grep -lri --exclude='searchResults.md' --exclude='allNotes.md' "$searchString" "$noteDirname")

  # Check if there were any matches
  if [ "$matchCount" -eq 0 ]; then
    echo "No notes found containing \"$searchString\"."
  else
    # Execute the Vim command
    eval $vimCommand
  fi
}

function halp {
  cat << EOF
Vim-based Note Management Helper Functions
------------------------------------------

NT(1)                 Vim Note Management Utilities                NT(1)

NAME
    nt    Create a new note for today and opens it in Vim.
    ntc   Concatenate all notes into a single file and opens it in Vim.
    ns    Search notes for a specified string and display matches.
    nsc   Search notes for a specified string, compile matching notes,
          and open the compilation in Vim.
    nse   Search for a string in all notes and open each match in a new
          Vim tab.

SYNOPSIS
    nt
    ntc
    ns <string>
    nsc <string>
    nse <string>

DESCRIPTION
    nt creates a new note file for the current day with a timestamp and
    automatically opens it for editing in Vim.

    ntc concatenates all existing note files into a file named allNotes.md
    and opens this file in Vim.

    ns searches through the notes for a specified string. It outputs the
    matching file contents directly to the console.

    nsc searches for a given string within all notes, compiles matching
    notes into a file named searchResults.md, and then opens this file in
    Vim for review.

    nse performs a search across all notes for the specified string. For
    each note containing the string, it opens the note in a new tab in Vim,
    facilitating easy editing and review.

OPTIONS
    <string>        The text string to search for within the notes.
EOF
}

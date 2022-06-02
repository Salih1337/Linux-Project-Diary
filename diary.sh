#!/bin/bash

function check_dependencies() {
	if [ ! "$(command -v dialog)" ]; then
		echo 'This script depends on "dialog" to run!'
		exit 1
	elif [ ! "$(command -v glow)" ]; then
		echo 'We recommend you to use "glow'
	fi
}

function get_date() {
	diary_date=$(dialog --ascii-lines --keep-tite --stdout --title "Select a date" \
		--calendar "Select a date:" 0 0)

	if [[ $diary_date =~ (..)/(..)/(....) ]]; then
		day=${BASH_REMATCH[1]}
		month=${BASH_REMATCH[2]}
		year=${BASH_REMATCH[3]}
	fi
}

function write_diary() {
	file_name=$1

	# Use nano as default editor for simplicity
	nano "$file_name.md"
	zip --encrypt "$file_name" "$file_name.md" &&
		mv "$file_name.zip" "./diaries/$(whoami)/" &&
		rm "$file_name.md"
}

# Extract diary from zip file, print content of diary and then remove the diary file (Zip file will still exist)
function read_diary() {
	file_name=$1

	unzip "./diaries/$(whoami)/$file_name.zip"

	# If user hasn't installed glow, use cat to read files
	glow "$file_name.md" 2>/dev/null || cat "$file_name.md"
	rm "$file_name.md"
}

# Extract diary from zip, write to it with nano and then rezip it
function edit_diary() {
	file_name=$1

	unzip "./diaries/$(whoami)/$file_name.zip" 2>/dev/null
	write_diary "$file_name"

	# Note: We could have done this whole editing thing within the read_diary function, that's right
	# But for the sake of readability (I'm just scared of changing the code), I simply refuse to do it.
}

function main() {
	check_dependencies

	while getopts ':w:r:e:' FLAG; do
		case "$FLAG" in
		w)
			get_date

			file_name="$day-$month-$year-$OPTARG"
			write_diary "$file_name"
			;;
		r)
			get_date

			file_name="$day-$month-$year-$OPTARG"
			read_diary "$file_name"
			;;
		e)
			get_date

			file_name="$day-$month-$year-$OPTARG"
			edit_diary "$file_name"
			;;
		?)
			echo 'Unknown command!'
			echo $'To read a diary: /diary.sh -r [diary_name]\nTo write a new diary: /diary.sh -w [diary_name]\nTo edit a diary: ./diary.sh -e [diary_name]'
			exit 1
			;;
		esac
	done

	if [ ! -d "./diaries/$(whoami)" ]; then
		mkdir -p "./diaries/$(whoami)/"
	fi
}

main "$@"

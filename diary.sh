#!/bin/bash

function check_dependencies() {
	if [ ! "$(command -v dialog)" ]; then
		echo 'This script depends on "dialog" to run!'
		exit 1
	elif [ ! "$(command -v glow)" ]; then
		echo 'We recommend you to use "glow'
	fi
}

function help() {
	echo $'Cool diary tool\n'
	echo 'USAGE:'
	echo $'\t./diary.sh [OPTIONS] [FILE_NAME]\n'

	echo 'OPTIONS:'
	echo $'\t-w \t Write a new diary'
	echo $'\t-r \t Read contents of a diary'
	echo $'\t-e \t Edit diary'
	echo $'\t-l \t List all diaries'
	echo $'\t-q \t Add a new quote'
	exit 0
}

function get_date() {
	diary_date=$(dialog --ascii-lines --keep-tite --stdout --title "Select diary date" \
		--calendar "Select diary date:" 0 0)

	if [[ $diary_date =~ (..)/(..)/(....) ]]; then
		day=${BASH_REMATCH[1]}
		month=${BASH_REMATCH[2]}
		year=${BASH_REMATCH[3]}
	fi
}

function input_box() {
	inputbox=$1

	quote=$(dialog --keep-tite --stdout --title "Create Directory" \
		--inputbox $inputbox 8 40)

	echo $quote
}

function write_diary() {
	file_name=$1

	# Use nano as default editor for simplicity
	nano "$file_name.md"
	zip --encrypt "$file_name" "$file_name.md" >/dev/null &&
		mv "$file_name.zip" "./diaries/$(whoami)/" &&
		rm "$file_name.md"
}

# Extract diary from zip file, print content of diary and then remove the diary file (Zip file will still exist)
function read_diary() {
	file_name=$1

	unzip "./diaries/$(whoami)/$file_name.zip" >/dev/null &&
		(glow "$file_name.md" 2>/dev/null || cat "$file_name.md") &&
		rm "$file_name.md"
}

# Extract diary from zip, write to it with nano and then rezip it
function edit_diary() {
	file_name=$1

	unzip "./diaries/$(whoami)/$file_name.zip" >/dev/null
	write_diary "$file_name"

	# Note: We could have done this whole editing thing within the read_diary function, that's right
	# But for the sake of readability (I'm just scared of changing the code), I simply refuse to do it.
}

function add_quote() {
	file_name=$1
	quote=$2

	unzip "./diaries/$(whoami)/$file_name.zip" >/dev/null

	# Check if there is a place for us to add new quotes
	if [ ! "$(grep -m 1 "Quotes:" "$file_name.md")" ]; then
		echo "Quotes:" >>"$file_name.md" # If not, make it
	fi

	# Add a new quote after the Quotes string, zip the file, move it to diaries directory, then remove the leftovers
	sed -i "/Quotes:/ a $quote" "$file_name.md" &&
		zip --encrypt "$file_name" "$file_name.md" &&
		mv "$file_name.zip" "./diaries/$(whoami)/" &&
		rm "$file_name.md"

}

function main() {
	check_dependencies

	if [ $# -eq 0 ]; then
		help
	fi

	if [ ! -d "./diaries/$(whoami)" ]; then
		mkdir -p "./diaries/$(whoami)/"
	fi

	while getopts ':q:w:r:e:lh' FLAG; do
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
		l)
			ls "./diaries/$(whoami)/"
			;;
		q)
			get_date
			input_box "Quote:"
			file_name="$day-$month-$year-$OPTARG"

			add_quote "$file_name" "$quote"
			;;
		h)
			help
			;;
		?)
			echo $'Unknown command!\n'
			echo 'For more information, try -h flag'
			exit 1
			;;
		esac
	done
}

main "$@"

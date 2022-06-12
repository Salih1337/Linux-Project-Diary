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
	exit 0
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

	unzip "./diaries/$(whoami)/$file_name.zip" &&
		(glow "$file_name.md" 2>/dev/null || cat "$file_name.md") &&
		rm "$file_name.md"
}

# Extract diary from zip, write to it with nano and then rezip it
function edit_diary() {
	file_name=$1

	unzip "./diaries/$(whoami)/$file_name.zip"
	write_diary "$file_name"

	# Note: We could have done this whole editing thing within the read_diary function, that's right
	# But for the sake of readability (I'm just scared of changing the code), I simply refuse to do it.
}

function main() {
	check_dependencies

	if [ $# -eq 0 ]; then
		help
	fi

	if [ ! -d "./diaries/$(whoami)" ]; then
		mkdir -p "./diaries/$(whoami)/"
	fi

	while getopts ':w:r:e:lh' FLAG; do
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
#!/bin/bash

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
	# Use nano as default editor for simplicity
	nano "$1.md"
	zip --encrypt $1 "$1.md" && \
		mv "$1.zip" ./diaries} && \
		rm "$1.md"
}

function main() {
	while getopts ':w:r:' FLAG; do
		case "$FLAG" in
		 	w )
				# Todo: fix this mess
				if [ "$OPTARG" == "" ]; then 
					echo 'You need to pass a name for your new diary!'
					exit 1
				fi

				get_date

				file_name="$day-$month-$year-$1"
				write_diary $file_name				
		 		;;
		 	r )
				echo "$OPTARG"
				;;
			? )
				echo 'Wrong usage'
				;;
		 esac 
	done

	if [ ! -d "./diaries" ]; then
		mkdir ./diaries
	fi
}

main "$@"
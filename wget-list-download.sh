#!/bin/bash
#
# Download and rename items using wget from a list within a file. 
#
# See HelpMenu function for usage and list formatting. 
#
# Updated 2019-02-25

function HelpMenu(){
	printf "\nHelp:\n"
	printf "  Script usage: ./wget-list-download.sh listFilename\n"
	printf "  File list format: filename.ext|download-url\n\n"
	printf "  To call this help menu again, use '--help'\n\n"
}

function CheckParam(){
	if [ "$1" == "--help" ]; then # Help printout.
		HelpMenu
		exit 0
	elif [ "$#" -eq 0 ]; then # If there isn't an input parameter. 
		printf "No input file specified!\n"
		HelpMenu
		exit 1
	elif [ "$#" -gt 1 ]; then # If there are too many input parameters.
		printf "Too many parameters specified!\n"
		HelpMenu
		exit 1
	elif [ "$#" -eq 1 ] && [ ! -f "$1" ]; then # If the input parameter is not a regular file. 
		printf "Input parameter is not a regular file!\n"
		HelpMenu
		exit 1
	elif [ "$#" -eq 1 ] && [ -f "$1" ]; then # If the input parameter is a single, regular file.
		printf "\n"
		downloadList="$1"
	fi
}

function DownloadFiles(){
	if [ ! -z "$downloadList" ]; then # Check that the $downloadList variable isn't empty. 
		while IFS=' | ' read -r fileName url; do
			printf "Filename: $fileName\n"
			wget -q --show-progress -O "$fileName" "$url"
			printf "\n"
		done < "$downloadList"
	fi
}

CheckParam $@ # Check the parameters supplied, with all script paramaters as an input.
DownloadFiles # Download the files. 
exit 0
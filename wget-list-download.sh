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

function GetScreenInstallStatus(){
	screenPkgName=screen
	if dpkg --get-selections | grep -q "^$screenPkgName[[:space:]]*install$" >/dev/null; then # Check if user has the "screen" package installed. 
		return 0;
	else 
		return 1;
	fi
}

# Check if this script is already in a Screen session.
function AskForScreen(){
	if GetScreenInstallStatus; then # If the screen package is installed. 
		if [ ! -n "$STY" ]; then # If this script isn't in a Screen session.
			while true; do
				read -p "Do you want to re-open this script in a Screen session? (y/n) " -e screenSession # Ask for user input.
				case $screenSession in
					[Yy]* ) ReopenInScreen;; # If we do want to run in a Screen Session.
					[Nn]* ) printf "\n" && break;; # If we don't, just continue.
					* ) printf "\nInvalid input\n";;
				esac
			done
		else # If this script is in a Screen session.
			printf "Screen usage:\n"
			printf "  To detach from a Screen session: CTRL A, then CTRL D\n"
			printf "  To re-attach to this Screen session: 'screen -r wget-list-download'\n\n"
		fi
	else 
		return # If screen isn't installed, just return and run without screen functions. 
	fi
}

function ReopenInScreen(){
	exec screen -L -Logfile "$downloadList-wget-list-download.log" -S wget-list-download /bin/bash "$0" "$downloadList"; # Start a new instance of this script with same parameters within a Screen session... 
	exit 0 # ... and exit this instance. 
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
AskForScreen # Check if the user has the screen package installed. If so, ask if they want to run this script is a Screen session.
DownloadFiles # Download the files. 
exit 0
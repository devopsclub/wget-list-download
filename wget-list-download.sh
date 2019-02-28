#!/bin/bash
#
# Download and rename items using wget from a list within a file. 
#
# Run with '-h' to view help printout.  

screenFlag='false'
downloadList=''
parameters='' 

function CheckOptions(){
	while getopts 'shl:' flag; do
	  case "${flag}" in
		s) screenFlag='true' ;;
		h) PrintHelp && exit 0 ;;
		l) downloadList="${OPTARG}" ;;
		*) PrintHelp && exit 0 # If there's an argument we don't recognize, exit. 
		exit 1 ;;
	  esac
	done	
	
	
	if [ $# -eq 0 ]; then # If no arguments are passed, print help and exit. 
		printf "\nNo argument specified.\n"
		PrintHelp
		exit 1
	elif [ -z $downloadList ]; then # If there is no list file specified. 
		printf "\nNo list file specified.\n"
		PrintHelp
		exit 1
	fi
}

function PrintHelp(){
	printf "\nHelp:\n"
	printf "  Usage: ./wget-list-download.sh -l listFile.ext\n\n"
	printf "  File list format: filename.ext|download-url\n\n"
	printf "  Options:\n"
	printf "    -h                Print help menu.\n"
	printf "    -l [listFile]     REQUIRED. Specify the location of the list file.\n"
	printf "    -s                Run the downloads within a Screen session.\n"
	printf "\n"
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
function CheckScreen(){
	if $screenFlag; then # If the Screen flag is true. 
		if GetScreenInstallStatus; then # If the screen package is installed. 
			if [ ! -n "$STY" ]; then # If this script isn't in a Screen session.
				ReopenInScreen
				exit 0
			else # If this script is in a Screen session.
				printf "Screen session name: $STY\n\n"
				printf "Screen usage:\n"
				printf "  To detach from a Screen session: CTRL A, then CTRL D\n"
				printf "  To re-attach to this Screen session: 'screen -r wget-list-download'\n\n"
			fi
		else 
			printf "Screen is not installed."
			return # If screen isn't installed, just return and run without screen functions. 
		fi
	fi
}

function ReopenInScreen(){
	dateTimeString=$(date +'%Y%m%d-%H%M%S')
	printf "Re-opening in a Screen session. \nLog file: $dateTimeString-$downloadList-wget-list-download.log"
	exec screen -L -Logfile "$dateTimeString-$downloadList-wget-list-download.log" -S wget-list-download /bin/bash "$0" "$parameters"; # Start a new instance of this script with same parameters within a Screen session... 
}

function DownloadFiles(){
	printf "\nDownloading files from list: $downloadList\n\n"
	if [ ! -z "$downloadList" ]; then # Check that the $downloadList variable isn't empty. 
		if [ -f "$downloadList" ]; then # Check if the list file parameter is a real file. 
			while IFS='|' read -r fileName url; do
				printf "Filename: $fileName\n"
				wget -q --show-progress -O "$fileName" "$url"
				printf "\n"
			done < "$downloadList"
		else 
			printf "\nThe list file is not readable.\n"
		fi
	else 
		printf "\nNo list file supplied. Exiting.\n"
		exit 1
	fi
}

parameters="$@" # Store the the parameters that were passed to this script, as getopts within the CheckOptions function clears $@.
CheckOptions $@
CheckScreen
DownloadFiles
exit 0
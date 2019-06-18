# wget-list-download.sh

Bash script to download and rename items from a file using wget. 

### To Download:
	wget 'https://raw.githubusercontent.com/falling-fading/wget-list-download/master/wget-list-download.sh' && chmod +x ./wget-list-download.sh 

### Usage:
./wget-list-download.sh -l [pathToListFile]

### List file:
File format: <filename.ext>|<download-url>

###### Example: 
	nameOfMyDownload.Extension|https://thingIWantToDownload
	secondThingIWantToDownload.Extension|https://secondThingIWantToDownload
	thirdThingIWantToDownload.Extension|https://thirdThingIWantToDownload

### Options:
    -h                Print help menu.
    -l [listFile]     REQUIRED. Specify the location of the list file.
    -s                Run the downloads within a Screen session. User must have Screen installed. 

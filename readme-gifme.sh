#!/bin/bash
source ./scripts/pretty.sh
source ./scripts/fetch.sh

if [ ! -f "$readmeFile" ]; then
    # Create Readme file
    touch $readmeFile
fi

if [ ! -f "$responseFile" ]; then
    # Create response file
    touch $responseFile
fi

gifId=$(head -n 1 $responseFile)
gitURL="![Alt Text](https://media.giphy.com/media/$gifId/giphy.gif)"
firstLineOfReadme=$(head -n 1 $readmeFile)

# The readme file should exist in the first line.
if [[ $firstLineOfReadme == *"media.giphy.com"* ]]; then
    # TODO: Lets make this cleaner, replace in are where located.
    grep -v "media.giphy.com" $readmeFile > tmpfile && mv tmpfile $readmeFile
    echo $gitURL | cat - $readmeFile > temp && mv temp $readmeFile
    cat $readmeFile
else
    echo $gitURL | cat - $readmeFile > temp && mv temp $readmeFile
    cat $readmeFile
fi
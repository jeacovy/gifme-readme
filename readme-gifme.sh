#!/bin/bash
echo "Display echo below:"
echo $GIPHY_API_KEY_DEV

if [ !$GIPHY_API_KEY_DEV ]; then
    echo "GIPHY API Key is required."
    exit 1;
fi

# Settings for GIPHY
tag="mood"
rating="g"
giphyEndpoint="api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY_DEV&tag=$tag&rating=$rating" 

# Local 
responseFile="temp"
readmeFile="README.md"

touch $responseFile

# Hit enpoint
curl $giphyEndpoint | python -c "import sys, json; f = open('$responseFile', 'w'); f.write(json.load(sys.stdin)['data']['id']); f.close()"

if [ ! -f "$readmeFile" ]; then
    # Create Readme file
    touch $readmeFile
fi

gifId=$(head -n 1 $responseFile)
gitURL="![Alt Text](https://media.giphy.com/media/$gifId/giphy.gif)"
firstLineOfReadme=$(head -n 1 $readmeFile)

if [ !$gifId ]; then
    echo "The GIPHY ID is missing. Confirm that your GIPHY API Key is correct."
    exit 1;
fi

# The readme file should exist in the first line (room for improvement)
if [[ $firstLineOfReadme == *"media.giphy.com"* ]]; then
    grep -v "media.giphy.com" $readmeFile > tmpfile && mv tmpfile $readmeFile
    echo $gitURL | cat - $readmeFile > temp && mv temp $readmeFile
    cat $readmeFile
else
    echo $gitURL | cat - $readmeFile > temp && mv temp $readmeFile
    cat $readmeFile
fi

# Create a commit with just the read me file
# OPTIONAL!
GIT='git --git-dir='$PWD'/.git'
GIT add README.md
GIT commit -m "👾 is it pronounce Gif or Gif?"
GIT push

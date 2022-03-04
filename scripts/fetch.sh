#!/bin/bash
api_key="[GIPHY_API_KEY]"
tag="space"
rating="g"
responseFile="./response/response.txt"
readmeFile="README.md"
oldGifId=""

if [-f "$responseFile" ]; then
    oldGifId=$(head -n 1 $responseFile)
fi


url="api.giphy.com/v1/gifs/random?api_key=$api_key&tag=$tag&rating=$rating" 
curl $url | python -c "import sys, json; f = open('$responseFile', 'w'); f.write(json.load(sys.stdin)['data']['id']); f.close()"
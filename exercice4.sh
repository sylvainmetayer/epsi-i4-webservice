#/bin/sh
clear
NAME=${1:-Sylvain}
LINK=${2:-http://google.com}
DESC=${3:-Description}
CURL_FILE=output.txt
MON_ID=mon-id
BASE_URL=http://rest-bookmarks.herokuapp.com/api/bookmarks/

echo "Create Bookmark (POST)"

# FIRST CURL
echo "Let's create a new bookmark for this exercise"
curl -s -X POST ${BASE_URL} --data-binary "name=${NAME}&description=${DESC}&url=${LINK}" -D $CURL_FILE > /dev/null

url=http:$(cat $CURL_FILE | grep Location | cut -d":" -f 3)
url=${url%$'\r'}

echo "Infos about the created bookmark"
curl -s -X GET $url -D $CURL_FILE
echo 

modified_since=$(cat $CURL_FILE | grep Last-Modified | cut -d":" -f 2- | tr -d "," | xargs)
etag=$(cat $CURL_FILE | grep Etag | cut -d":" -f 2- | tr -d "\"" | xargs)

# First CURL Request
echo "DEBUG"
echo $modified_since
echo $url
echo "END DEBUG"
echo
curl -v $url --header "If-Modified-Since: $modified_since" -D - 
# This command work manually, but in a script, it return a Bad Request HTTP Error.
# The modified_since and url variable are printed to screen to replay the command manually and assert it is correct 
echo 

# Second CURL Request
echo "Create an element at a custom URL"
curl -X PUT ${BASE_URL}${MON_ID} --data-binary "name=${NAME}CUSTOM&description=${DESC}CUSTOM&url=${LINK}CUSTOM" -D -
echo 
echo "Assert that we cannot create an element with a /${MON-ID} url"
curl -X PUT ${BASE_URL}${MON_ID} --data-binary "name=${NAME}CANNOTEDIT&description=${DESC}CANNOTEDIT&url=${LINK}CANNOTEDIT" -H "If-None-Match: *" -D -
echo 
echo "Assert that the current representation of the element is the original one"
curl -X GET ${BASE_URL}${MON_ID}
echo

# Last CURL Request
echo "Delete an invalid element"
echo "Because we set a precondition that should always fail in this case, we'll have an 412 error"
curl -X DELETE http://rest-bookmarks.herokuapp.com/api/bookmarks/INVALID --header "If-Match: *" -D -

rm $CURL_FILE

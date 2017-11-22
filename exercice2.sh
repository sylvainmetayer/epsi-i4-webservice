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
curl -s -X POST ${BASE_URL} --data-binary "name=${NAME}&description=${DESC}&url=${LINK}" -D $CURL_FILE > /dev/null

url=http:$(cat $CURL_FILE | grep Location | cut -d":" -f 3)
url=${url%$'\r'}

echo "Accessing Bookmark at URL ${url}"
# SECOND CURL
curl -s -X GET $url
echo

echo "Other way to create Bookmark (PUT)"
# FIRST CURL OTHER WAY
curl -s -X PUT ${BASE_URL}${MON_ID} --data-binary "name=${NAME}2&description=${DESC}2&url=${LINK}2" > /dev/null
custom_url=${BASE_URL}${MON_ID}
echo "Accessing $custom_url"
curl -s -X GET $custom_url
echo

echo "Delete Custom Resource (Created w/ PUT)"
# FOURTH CURL
curl -s -X DELETE $custom_url > /dev/null

echo "Update First Bookmark"
# THIRD CURL
curl -s -X PUT $url --data-binary "name=${NAME}UPDATE&description=${DESC}UPDATE&url=${LINK}UPDATE" > /dev/null
echo "See !"
curl -s -X GET $url
echo

echo "Update latest Bookmark"
# FIFTH CURL
curl -s -X PUT ${BASE_URL}latest --data-binary "name=${NAME}LATEST&description=${DESC}LATEST&url=${LINK}LATEST" -D $CURL_FILE > /dev/null
url_update_latest=http:$(cat $CURL_FILE | grep Location | cut -d":" -f 3)
url_update_latest=${url%$'\r'}
curl -s -X PUT ${url_update_latest} --data-binary "name=${NAME}LATEST&description=${DESC}LATEST&url=${LINK}" > /dev/null
curl -s -X GET ${BASE_URL}latest 
echo

rm $CURL_FILE

#!/bin/sh
clear

URL=http://rest-bookmarks.herokuapp.com/api/bookmarks/latest

echo "Defaut : JSON"
curl -X GET ${URL}
echo

echo "Content negociation : Let's get 406 Error (Text plain unsupported)"
curl -X GET ${URL} --header "Accept: text/plain"
echo

echo "Now, let's get XML"
curl -X GET ${URL} --header "Accept: application/xml"
echo

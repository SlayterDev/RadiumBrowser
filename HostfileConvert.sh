#!/bin/bash
# Script to convert a standard host file into a ad block list we can use in Radium

read -p 'Host file location: ' hostloc
read -p 'Output file name: ' outputfile

curl -ls $hostloc | grep -E '^[0-9]' | grep -v -E '\s*localhost\s*$' | perl -pe 's/^[0-9.]+\s(\S+)\s*.*$/"$1",/mg' | perl -pe 's/\n//g' | perl -pe 's/\A(.+),\z/[{"trigger":{"url-filter":".*","if-domain":[$1]},"action":{"type":"block"}}]/g' | tr "[:upper:]" "[:lower:]" > $outputfile

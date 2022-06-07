#!/bin/bash

# This code takes in two filenames as arguments.
# The 1st is a massaged/uniqed version of order data
# The 2nd is a list of zip codes (1 per line) to match

# read in one line at a time from 1st arg (file with address info)
while read -r line; do
  # grab last comma separated field from line (zip)
  lastfield=`echo $line | awk -F, '{print $NF}'`
 
  # read in one line at a time from 2nd arg (file with list of zips)
  while read -r zip; do
    # strip of wonky annoying ^M chars from zip code
    zipstrip1=`echo ${lastfield} | sed  's///'`
    
    # strip off leading single quote, but only if exists
    # data isn't consistent as doesn't always exist
    zipstrip=`echo ${zipstrip1} | sed  "s/^'//"`

    # if zip from address equals zip from file
    if [[ $zip == $zipstrip ]]; then

      # split line and grab 1st field (name)
      name=`echo $line | awk -F, '{print $1}'`

      # check 2nd field to see if there is a double-quote
      # if double-quote means address has apartment number
      secondfield=`echo $line | awk -F, '{print $2}'`
        if [[ $secondfield =~ ^\" ]]; then
          # split line using double-quote delimiter and store addy
          address=`echo $line | awk -F\" '{print $2}'`
        else
          # no apartment number, so just take address wholesale
          address=$secondfield
        fi

      # city and state are consistent and are 2nd to last and 3rd to last fields
      city=`echo $line | awk -F, '{print $(NF-2)}'`
      state=`echo $line | awk -F, '{print $(NF-1)}'`

      # display address
      echo "$name, $address, $city, $state, $zip"
    fi
  done <$2
done <$1

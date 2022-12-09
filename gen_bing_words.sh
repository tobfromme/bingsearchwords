#!/bin/bash

# Define variables.  Ensure KEYWORDLIST points to the correct file and your user has access to it.
KEYWORDLIST="/usr/lib/python3.10/site-packages/bing_rewards/data/keywords.txt"
DOWNLOADFILE="searches.txt"

updatewords() {
	# Download latest Google searches
	/usr/bin/curl -s "https://trends.google.com/trends/trendingsearches/daily/rss?geo=US" > ${DOWNLOADFILE}

	# Grab anything with a <title> tag.  These are the searches.
	/usr/bin/sed -i '/<title>/!d' ${DOWNLOADFILE}
	
	# Next, remove the "Daily Search Trends" line, strip all HTML tags, and remove leading spaces
	/usr/bin/sed -i '/Daily Search Trends/d;s/<title>//;s/<\/title>//;s/^[ \t]*//' ${DOWNLOADFILE}

	# Count number of lines in daily search
	SEARCHCOUNT=$(/usr/bin/wc -l ${DOWNLOADFILE} | /usr/bin/awk '{print $1}')

	# Remove the number above from the keyword list
	echo "Before count of keywords.txt: $(wc -l ${KEYWORDLIST})"
	/usr/bin/sed -i "1,${SEARCHCOUNT}d" ${KEYWORDLIST}

	# Let's update the year
	CURRENTYEAR=$(date +%YYYY)
	/usr/bin/sed -i "s/2[0-9][0-9][0-9]/${CURRENTYEAR}/g" ${KEYWORDLIST}

	# Now append the Google searches to the keyword list
	cat ${DOWNLOADFILE} >> ${KEYWORDLIST}

	# Sanity check on the final count
	echo "After count of keywords.txt:  $(wc -l ${KEYWORDLIST})"
}

# Test if the keyword list has been updated in the past 24 hours.  If so, abort, as you'll end up with duplicates and less meaningful searches.
if test $(find ${KEYWORDLIST} -mmin +1435); then
	updatewords
# Living on the wild side, eh?  Add "--force" to the script, because you know what you're doing.
elif [[ "$1" == "--force" ]]; then
	updatewords
else
	echo "Can only run once every 24 hours.  Aborting"
	exit 1
fi

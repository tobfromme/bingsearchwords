Param(
    [string] $forceFlag
 )

 Start-Transcript "$PSScriptRoot\tom.txt"

 $KEYWORDLIST="C:\Program Files\Python311\Lib\site-packages\bing_rewards\data\keywords.txt"
 $DOWNLOADFILE="$PSScriptRoot\searches.txt"
 $TEMPFILE="$PSScriptRoot\tempfile.txt"

function updatewords {
    # Connect to Google and download their latest daily trending searches
    Invoke-WebRequest https://trends.google.com/trends/trendingsearches/daily/rss?geo=US -OutFile $DOWNLOADFILE

    # Begin cleanup from HTML

    # Grab anything with <title> tags (the searches) and remove the 'Daily Search Trends' line
    Get-Content $DOWNLOADFILE | Where-Object { $_ -match '<title>' -and $_ -notmatch 'Daily Search Trends' } | Set-Content $TEMPFILE

    # We are left with the search words in <title> tags.  Let's remove all HTML and any leading/traililng spaces
    ((Get-Content $TEMPFILE) -replace '<[^>]+>','').Trim() | Set-Content $DOWNLOADFILE

    # For sanity, let's do some arithmetic
    
    # Grab the number of searchs from Google
    $SEARCHCOUNT=$(Get-Content $DOWNLOADFILE | Measure-Object -Line).Lines

    # Grab the number of keywords in the current file
    $KEYWORDCOUNT=$(Get-Content $KEYWORDLIST | Measure-Object -Line).Lines
    Write-Host "Before count of keywords.txt:  $KEYWORDCOUNT"
    
    # To keep the keywords file from growing indefinitely, let's remove the number of lines from the top equal to the number of Google searches
    (Get-Content $KEYWORDLIST -Raw) -replace "^(?:.*\r?\n){$SEARCHCOUNT}" | Set-Content -NoNewLine $KEYWORDLIST

    # Now, the number of keywords should have decreased by the number of Google searches
    #  i.e. <Current count> = <Original Keyword Count> - <Google Search Count>
    $KEYWORDCOUNT=$(Get-Content $KEYWORDLIST | Measure-Object -Line).Lines
    Write-Host "During count of keywords.txt:  $KEYWORDCOUNT"
    
    # Write the Google searches to the end of the keyword list.
    Get-Content $DOWNLOADFILE | Out-File -FilePath $KEYWORDLIST -Append

    # Another sanity check.  This count should match the "before count"
    $KEYWORDCOUNT=$(Get-Content $KEYWORDLIST | Measure-Object -Line).Lines
    Write-Host "After count of keywords.txt:  $KEYWORDCOUNT"
    
    # Cleanup of temporary file(s)
    Remove-Item $TEMPFILE
}

# Logic of when to update words.  Recommended is once per day.
# You don't want to run this too often, otherwise you'll end up with many duplicates in your keyword list.

# Grab the last modified date of the keyword file and the current date
$KEYWORDMODIFIED=(get-childitem $KEYWORDLIST).LastWriteTime
$NOW=$(Get-Date)

# Compare the two.  The modified date of keyword should be at least 23 hours ago.
if (($NOW - $KEYWORDMODIFIED).TotalHours -gt 23) {
    updatewords
}
# So you want to run anyway, eh?  Add "--force" to the script.
elseif ($forceFlag -eq "--force") {
    updatewords
}
else {
    Write-Host "Can only run once every 24 hours.  Aborting."
    Exit
}

Stop-Transcript
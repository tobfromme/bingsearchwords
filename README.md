Using the script from here:  [bing-rewards](https://github.com/jack-mil/bing-rewards "Bing Rewards")

I wanted the keywords.txt file to be updated with relevant searches, not things from several years ago.

Two scripts are provided:

- gen_bing_words.ps1:  Tested with PowerShell 7.3 on Windows 11 only
- gen_bing_words.sh:   Tested on Arch Linux and Fedora 36/37

# Installation:

- Install bing-rewards *first*.  I run it fine with Python 3.11.0.

- Download the appropriate files for your system.
   For Linux, your home directory is fine.
   For Windows, I recommend creating C:\Scripts and saving there.  Otherwise, you'll need to edit the script.

- Update the script to the correct location of keywords.txt (the KEYWORDLIST variable)

- Schedule using cron (Linux) for 1am:

     ```echo "0 1 * * * bash ~/gen_bing_words.sh > ~/updatewords.txt" | crontab```

- Schedule using Task Scheduler (Windows) for 1am:
     Click Start
     Type "Task Scheduler"
     Right-click "Task Scheduler Library" on the left
     Click "Import Task"
     Browse to the downloaded "Generate Bing Keywords.xml" file.
     Click OK.

# Important Notes *before executing*:

## All:

   The script will only modify the keywords.txt file once per day by default.  This is to ensure it is not overrun with the same keywords, thus making your automated searches ineffective.

   However, if you like to throw caution to the wind, add "--force" at the end of either script:

      gen_bing_words.sh --force
      gen_bing_words.ps1 --force

## Windows:  

   You must run with Administrator, unless you have modified the permissions of the keywords.txt file to allow your user to write to it (recommended) or disabled UAC.  You can do so by:

     1.  Right-clicking the keywords.txt file > Properties > Security
     2.  Click "Edit"
     3.  Click "Add"
     4.  Click "Advanced"
     5.  Click "Object Types"
     6.  Uncheck everything but "Users"
     7.  Click "Find Now"
     8.  Select your user from the list.  It should not have an arrow pointing down (indicating disabled) on the icon.
     9.  Click "OK"
     10. Click "OK" again
     11. Highlight your user in the list
     12. Click "Full Control"
     13. Click "OK"

## Linux:

   Ensure the user running the script has write permissions on the keywords.txt file.  You can do so by:

     sudo to root

     ```chown <your username> /path/to/keywords.txt```
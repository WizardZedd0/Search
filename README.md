# Search:
 AutoHotkey Version: 1.1.23.01
 Language:       English
 Platform:       Windows 10
 Author:         WizardZedd
 Version:        0.9.2

# Script Function:
	    Performs searches with various options using the SearchGoogle Function (documentation below).
# Hotkeys:
       f2::        shows search gui
       esc::       hides search gui
       alt-f2::    search for currently selected text

# Search Manager:
       Remembers your searches, and tries to guess your search based off of past searches.

# Limitations:
       Hitting the enter key when the search combobox is expanded does not begin search, 
       in this case the enter key must be hit 2 times. (I'm looking for a fix.)
       
# Function SearchGoogle:
 Author: Wizard Zedd
 Search Google: originally just for searching google, but was further expanded to youtube
                 by using the /y option or putting "youtube" in the searchquery. This function
                 can also have many other use cases.
 searchQuery: The term to search for with any number of options at the beginning.
       Options: to add an option type /(option)
           /i  Images
           /v  Videos
           /s  Shop
           /n  News
           /d  Define
           /t  Time Frame
           /td     Last Day
           /tw     Last Week
           /tm     Last Month
           /tmn    Last n Months
           /ty     Last Year
           /w(site)\   Does a site search
           /y      Youtube
           /r      Run First result (it finds)
 RunSearch: 
       True launches the Search Link
 RunRes:
       True launches the first link
 Returns: A list of links seperated by newlines(`n). The first link is to the search page.

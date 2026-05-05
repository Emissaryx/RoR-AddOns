A simple warhammer online addon which makes it easier for warband and siege leaders to communicate with their followers by broadcasting text sequences into chat. 

Functionality:

	* type /wlh show to open the addon
	* type /wlh config to open the addons configuration dialog
	
	* Leftclick on a message label to broadcast the message to the warband (/wb) channel, or the party (/p) channel when you are not in a warband
	* Rightclick on a message label to broadcast the message to the region (/1) channel
	* Leftclick on a LFM submenu entry to post it to the LFG (/5) channel

	* Click on a countdown label to start a countdown with the noted time, click it again to abort the countdown.

	* Click on a "ZONE" message label to dynamically select a zone. $Z in a message text will be replaced with the selected zone.

	* Click on a "LFM" message to specify the role you are looking for or choose AUTO mode to search for missing roles based on your current warband or party automatically.

----------------

Installation:

	* Get it from here: https://tools.idrinth.de/addons/wbleadhelper/

-----------------
1.0.8 - Updated as of 4/17/2026
* Fixed saved settings not loading reliably by declaring the saved-variables version in addon metadata.
* Prevented fallback sessions from overwriting existing saved settings on logout before a real settings table is loaded.

1.0.7 - Updated as of 4/15/2026
* Cleaned up the leftover middle-click hook from the 1.0.6 LFM /5 changes.
* Added AUTO LFM alt-spec detection so missing-role counts can treat flagged hybrid healers as DPS when appropriate.
* Added config options to disable alt-spec detection entirely or ignore RP/Zealot alt-spec flags only.

1.0.6 - Updated as of 11/25/2025
* Removed middle click and fixed /5 for LFM messages.

1.0.5 - Updated as of 11/5/2025
* Added middle click to send to /5 for LFM message.

1.0.4 - Updated as of 9/19/2025
* Added a Clone button to the Messages tab so existing messages can be duplicated quickly.
* Cloned entries auto-increment their label suffix to keep names unique.

1.0.3 - Updated as of 9/18/2025
* Fixed some move to zones not sending to chat (Thanks Sedetra for reporting that)

1.0.2 - Updated as of 9/17/2025
* Added smart channels so it can be used in party as well as warband

1.0.1 - Updated as of 9/16/2025
* Fixed small alignment issue with header

1.0.0 - Updated as of 9/16/2025
* Added BOs for T1-3 zones that are linked together (see pics)
* Added all but T1 zones to "Move to" zone button
* Organized BOs a little (go top to bottom or left to right depending on the zone)
* Moved keeps and posterns to their own column to clean up the UI.
* Changed height and width slightly to make a little more room for the longer names.


0.9.9 - Updated as of 9/14/2025
* Fixed my "fix" on the way zones are excluded from getting common BOs like keep and postern

0.9.8 - Updated as of 9/14/2025
* Added LotD BOs, changed the way zones are excluded from getting common BOs like keep and postern

0.9.7 - Updated as of 7/05/2022
* Fixed 2/2/2 auto search

0.9.6 - Updated as of 5/26/2022
* Chat channels can now be set in each message
* Bugfixes

0.9.5
* The LFG submenu is now editable as well.
* The AUTO group scan feature got more flexible. You can now define the number of missing roles you are looking for (Good for none warbands).
* Added help tooltips in more places.

0.9.1
* A tooltip with needed roles is now shown when hovering the *LFM* button.
* Line breaks in message labels are now done with <nl> not <br> anymore
* Some smaller bug fixes

0.9 - Updated as of 5/06/2022.
* A full config UI was added. Messages can now be added and changed from withing the game.
* Added AUTO looking for players search. It scans your warband and puts out a message with missing roles (healers, tanks, dps)
* Messages are in different colors now
* Reorderd the message labels to make them more intuitive to use
* Some small adjustments

0.7 - Updated as of 7/22/2020.
* Added "Color Mode", to be able to chat colored all the time.

0.6.5 - Updated as of 7/16/2020.
* Button text can now be colored
* Added "back" button to submenus
* Realigned text in buttons to better fit
* Submenus are now better recognizable

0.6 - Updated as of 7/13/2020.
* Added button to shout out a BO 
* Added a "Looking for Members" button which post to the /5 LFG channel on left click. Or to /1 on right click.
* Some bug fixes and code optimizations

0.5 - Updated as of 6/24/2020.
* Reworked countdown functionality

0.4 - Updated as of 6/24/2020.
* Improved window scaling
* Added more messages
* Added a new layout (two button rows) 
* Added mouse over button color change 

0.3 - Updated as of 6/06/2020.
* Added a Zone announcement message

0.2.3 - Updated as of 6/04/2020.
* Added a variable at the top of the document to make it possible to change the size of the window

0.2.2 - Updated as of 6/03/2020.
* Added a variable at the top of the document to make changing the text color easier

0.2 - Updated as of 6/02/2020.
* Initial Release

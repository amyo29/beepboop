# README

Team members: Amy Ouyang, Evan Peng, Sanjana Kapoor, Alvin Lo

Group number: 9

Name of project: beepboop

Dependencies: Xcode 12.4, Swift 5


## Final

### Running the application

Please open the file beepboop.xcworkspace (as opposed to the file beepboop.xcodeproj) in XCode, and run the application on an iPhone 12 simulator. 

### Note about Custom Alarm Ringtone

As of XCode 8.0+, notification sound duration is as follows:

When phone is unlocked and app is running in the background, sound plays once for 6 seconds then is cut off.
When phone is locked, sound plays for full duration (Apple has 30 seconds max limit).
In any case, the sound will stop once user clicks on the notification, swipes on the banner, adjusts volume/presses top right button on phone, or swipes down from the top to display Notification Center.
To configure the notification sound (alarm ringtone) to play for its full duration, one method is to go to the phone Settings > Notifications > beepboop and then set "Banner Style" to "Persistent". Note that the default Banner style setting is "Temporary", which plays notification sounds for a max duration of 6 seconds).
See https://developer.apple.com/forums/thread/66925 for more information.


### Overall Contributions

| Features           | Description                                                                          | Release Planned | Actual Release | Deviations                                                         | Work Distribution                   |
|--------------------|--------------------------------------------------------------------------------------|-----------------|----------------|--------------------------------------------------------------------|-------------------------------------|
| Loading Screen     | Screen that displays when app first loads                                            | Alpha           | Alpha          | N/A                                                                | Amy (50%) Alvin (50%)               |
| Login/Sign Up      | Login through email or FB/Google Auth                                                | Alpha           | Alpha          | N/A                                                                | Alvin (50%) Sanjana (50%)           |
| Overall UI Design        | Visual appearance of the application                                                 | Final           | Final          | Some screens are redesigned, some screens are added                                        | Amy (80%) Sanjana (20%) |
| Alarms             | Allowing users to create functional alarms that can be optionally shared to friends, and view their alarms in sorted order  | Alpha           | Alpha - Final  | Snooze is not functional. Added more selection of fun custom ringtones than originally planned.                                           | Amy (60%) Alvin (40%)               |
| Alarm Metadata     | A screen displaying alarm details, user response status, and members of this alarm                                    | Alpha           | Beta           | Unable to resend an alarm/trigger a remote push notification for a friend who hasn't responded to an alarm due to local notification limitations and lack of an Apple Developer License. Screen was redesigned to now show list of members for an alarm, as well as each member's live response status (Accepted/Snoozed) to an alarm. The list of users who declined an alarm invitation is not displayed anywhere (this is an intentional design choice).                                                               | Sanjana (80%) Amy (10%) Evan (10%)           |
| Friends            | Social feature to enable individual sharing of alarms                                | Beta            | Beta           |                   Unable to Edit or Block a friend.                                                | Alvin (60%) Amy (40%)               |
| Groups             | Social feature to enable sharing of alarm to specified group of people               | Final           | Final          |                   Groups notifications are not functional. Users do not receive a "You've been added to <groupName>" notification - they are automatically added to a group that is displayed on the Groups tab, and all of that group's shared alarms will now appear on the user's Home and Calendar pages.                                                |                  Sanjana (50%) Alvin (50%)                   |
| Calendar           | Displays calendar to show alarms scheduled on a specific day. Users can click on any date on calendar to create an alarm on that day                         | Final           | Final          | Better UI + increased functionality. Redesigned UI to split calendar (using FSCalendar) and alarm table view vertically on the Calendar screen. Added more functionality than originally designed - users can not only view but also edit and remove alarms from the calendar screen.                                                                | Amy (100%)                          |
| Profile            | Display user specific settings and data                                              | Beta            | Beta           | Blocked list is not functional. Can view username and email but cannot edit. Unable to delete user account.                                                               | Amy (50%) Evan (50%)                |
| Alarm Popup        | A screen that displays for a triggered alarm once the  alarm notification is clicked | Beta            | Final          | Changed from Snooze/accept/decline buttons to snooze and accept only. Snooze is not functional.                     | Sanjana (50%) Evan (50%)            |
| User Notifications | A screen displaying updates and changes related to  alarms, friends, and groups      | Beta            | Beta - Final   | Remote notifications implementation changed to local notifications | Evan (80%) Alvin (20%)              |

## BETA

### Running the application

Please run the application on an iPhone 12 simulator. 

### Contributions

#### Sanjana Kapoor (Release 20%, Overall 20%)
-  Created Alarm Popup Screen
- Worked on creating segue from navigation banner to Alarm Popup Screen (incomplete)
- Logic for Alarm Metadata page
- Logic for custom table view cells
- Assisted in Firebase database planning.
- Assisted with UI work on Launch, Login, and Sign Up screens
- Assisted with UI work on Home screen table view cells
- Bug fix on duplicate alarms on Home screen after creating alarms
- Login and Sign Up with FB/Google logic and related UI
- Snooze button UI on Alarm Creation screen

#### Alvin Lo (Release 30%, Overall 30%)
- Added functionality for removing alarms from Firestore
- Added functionality for sending/enabling/disabling notifications for individual alarms in Firestore
- Added new table view logic and alarm creation logic
- Setup logic for Firestore users collection
- Added functionality for storing user-specific alarms
- Majority of UI work on Launch, Login, and Sign Up screens
- Logic Alarm CoreData
- Logic for populating UI with data from CoreData and user input
- Logic for extracting time/date to display on alarm table view cells
- Logic for adding and deleting alarms on Home screen
- Logic for enabling/disabling Alarm notifications
- Login and Sign Up with email logic
- Firebase setup and related logic

#### Amy Ouyang (Release 40%, Overall 40%)
- Setup Firestore and migrated alarm data storage from Core Data to Firebase Firestore
- Configured Firestore backend integration and database
- Added functionality for automatic and immediate adding, retrieving, deleting, and modifying alarms in Firestore in real-time
- Added functionality for storing alarms in Firestore
- Added functionality for retrieving alarms in Firestore
- Added functionality for alarm recurrence 
- Add Friends screen UI and functionality
- Share Friends screen UI and functionality
- Majority of UI work on Home and Alarm Creation screens
- Home screen (table view and tab bar) UI and logic
- Logic for Alarm Creation view controller
- Logic for populating UI with data from CoreData and user input
- Logic for extracting time/date to display on alarm table view cells
- Logic for adding and deleting alarms on Home screen
- Logic for turning alarms on/off through a switch
- Logic for enabling/disabling Alarm notifications
- Logic for allowing notifications through user permissions
- Importing and setting custom fonts

#### Evan Peng (Release 10%, Overall 10%)
- Logic for Notifications Screen
- Logic for Profile/Settings Page
- Research and PoC on UIEventKit as an approach to notification triggers
- Managed issues on repository

### Deviations

#### Alarm Popup Screen
Originally, we were going to display this screen when users clicked on the
navigation banner when an alarm goes off. Unfortunately, we were unable
to find a way to do this. After comprehensive Google searches and attending
TA and Prof office hours, we've decided to push off this functionality to a later phase.

#### Adding Friends Screen
Simplified the UI design for the Contacts Screen. We decided to change the title
of the page to Friends. Then when adding friends, we changed the UI so that 
the user now will just enter the email and click the button to send the request. 
We made this change just to keep the UI simpler and more user friendly. 

#### Notification Screen
We decided to add in a new screen to the navigation bar only for Notifications. 
Here the user can see all notifications related to shared alarms, friend requests, etc.
We made this change so that the user would have a central place where they could 
see all their relevant notifications (hopefully making the experience easier).

#### Sharing
We have implemented the front end for sharing and are mid way implementing it
in the backend. We ran into some issues when implementing the backend that
took longer than expected to resolve. There is also an issue with opening the share screen
that causes the app to display an error message and not add an alarm as intended. 

#### Login/Sign Up Screens (Alpha)

We decided to slightly modify the design of these screens by integrating the
process of signing up with FB/Google into the Login screen, as per the 
recommendations from the initial design feedback. There is now a button on the
Login screen that takes a user from the Login screen to the Sign Up screen. 

#### Alarm Creation Screen (Alpha)

We modified the Alarm Creation screen from the initial design to now display 
time, date, and sound in Picker Views. The title is a customized text field. We
added a toggle for snoozing (no functionality). 

The user has the option to set the recurring option for an alarm on the UI. 
However, due to issues with notifications not anticipated, we have decided to 
move the recurring alarm notification functionality to a later phase.

#### Home Screen (Alpha)

The tab bar has been redesigned with a different set of icons, titles, and 
colors.

The Alarm Table View cell design deviates from the card style cells shown in the
initial design. The current design will be revisited in the future. 


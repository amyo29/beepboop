# README

## Alpha

### Running the application

Please run the application on an iPhone 12 simulator. 

### Contributions

#### Sanjana Kapoor (20%)
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

#### Alvin Lo (30%)
- Designed Firebase database
- Majority of UI work on Launch, Login, and Sign Up screens
- Logic Alarm CoreData
- Logic for populating UI with data from CoreData and user input
- Logic for extracting time/date to display on alarm table view cells
- Logic for adding and deleting alarms on Home screen
- Logic for enabling/disabling Alarm notifications
- Login and Sign Up with email logic
- Firebase setup and related logic

#### Amy Ouyang (40%)
- Designed Firebase database
- Logic for Friends + Add Friends screens
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

#### Evan Peng (10%)
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
took longer than expected to resolve. We've decided to push this to the final stage.

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


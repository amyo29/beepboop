# README

## Alpha

### Running the application

Please run the application on an iPhone 12 simulator. 

### Contributions

#### Sanjana Kapoor (20%)
- Assisted with UI work on Launch, Login, and Sign Up screens
- Assisted with UI work on Home screen table view cells
- Bug fix on duplicate alarms on Home screen after creating alarms
- Login and Sign Up with FB/Google logic and related UI
- Snooze button UI on Alarm Creation screen

#### Alvin Lo (30%)
- Majority of UI work on Launch, Login, and Sign Up screens
- Logic Alarm CoreData
- Logic for populating UI with data from CoreData and user input
- Logic for extracting time/date to display on alarm table view cells
- Logic for adding and deleting alarms on Home screen
- Logic for enabling/disabling Alarm notifications
- Login and Sign Up with email logic
- Firebase setup and related logic

#### Amy Ouyang (40%)
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
- Research and PoC on UIEventKit as an approach to notification triggers
- Managed issues on repository

### Deviations

#### Login/Sign Up Screens

We decided to slightly modify the design of these screens by integrating the
process of signing up with FB/Google into the Login screen, as per the 
recommendations from the initial design feedback. There is now a button on the
Login screen that takes a user from the Login screen to the Sign Up screen. 

#### Alarm Creation Screen

We modified the Alarm Creation screen from the initial design to now display 
time, date, and sound in Picker Views. The title is a customized text field. We
added a toggle for snoozing (no functionality). 

The user has the option to set the recurring option for an alarm on the UI. 
However, due to issues with notifications not anticipated, we have decided to 
move the recurring alarm notification functionality to a later phase.

#### Home Screen

The tab bar has been redesigned with a different set of icons, titles, and 
colors.

The Alarm Table View cell design deviates from the card style cells shown in the
initial design. The current design will be revisited in the future. 


# Alpha Release Checklist

## Main TODO

### Turn-in: code, readme

### Screens
- [x] Loading (UI and functionality)
- [x] Login (UI and functionality)
    - Redesign Login screen to have Create Account (small text) (remove Sign up screen)
- [x] Home w/ Navigation bar - UI and functionality (nav bar leads to empty screens)
    - Display list of alarms using core data
- [x] Alarm Creation - UI and functionality
    - https://developer.apple.com/documentation/eventkit

## TODO Breakdown by Screen

### Loading Screen
- [ ] Add drop shadow to logo

### Login/Sign-up Screens
- [x] Sign in using email
- [x] Sign up using email
- [x] Sign up using FB/Google
- [x] Set up Firebase authentication
- [ ] Back button to go back to sign in screen from sign up screen

### Home Screen
- [x] Set up table view for all alarms
    - [x] Fix issues with Image, Alarm title
    - [x] Properly populate each cell with saved data from CoreData
    - [x] Set up swipe-to-delete on alarm table cells
    - [x] Fix bug regarding alarms being double saved during load
- [x] Set up tab view visually
- [x] Click on the toggle by each alarm to turn on/off an alarm
    - [x] Implement toggle functionality
- [x] Click on the plus sign to create a new alarm on the Create/Edit Alarm screen

### Alarm Creation Screen
- [x] Create Alarm entity in CoreData
    - [x] Confirm entity attributes
- [x] Options to specify time, date, sound, and recurring
    - [x] Confirm correct functionality
- [x] Set up user input fields
- [x] Click on the “save” button to finalize the newly created alarm and navigate back to the Home Screen
- [x] ~~Click on the “Back” button to go back to the previous screen~~ Swipe down to go back to Home Screen

### Notification
- [x] Set up local notifications to pop up at designated time and date
    - [x] Correctly populate title and body in notifications
- [x] Cancel notifications when alarm is off/deleted


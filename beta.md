# Beta Release Checklist

## TODO Breakdown by Screen

### Loading Screen
- [ ] Add drop shadow to logo

### Login/Sign-up Screens
- [x] Sign in using email
- [x] Sign up using email
- [x] Sign up using FB/Google
- [x] Set up Firebase authentication
- [x] Back button to go back to sign in screen from sign up screen

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
- [x] ~~Create Alarm entity in CoreData~~
    - [x] ~~Confirm entity attributes~~
- [x] Options to specify time, date, sound, and recurring
    - [x] Confirm correct functionality
- [x] Set up user input fields
- [x] Click on the “save” button to finalize the newly created alarm and navigate back to the Home Screen
- [x] ~~Click on the “Back” button to go back to the previous screen~~ Swipe down to go back to Home Screen
- [x] Move alarm to Firebase Firestore
    - [ ] Retrieve alarms by user via API call
- [x] Implement recurring feature

### Alarm Popup Screen
- [ ] Direct users to alarm popup screen when users click on the notification shown when alarm triggers
- [ ] Snooze/Accept/Reject button
- [ ] Dots button to lead the user to the alarm response screen

alarmData collection -> alarm w/ userID
userData collection -> user w/ userID, [userID's], [alarmIDs]
userDoc
- userID: String
- profilePic: UIImage
- snoozeEnabled: Bool
- alarmIDs: [alarm uuids]
- contacts: [userIds]
- invites_received: [userIDs]
- invites_sent: [userIDs]
- notifications: 

### Notification
- [x] Set up local notifications to pop up at designated time and date
    - [x] Correctly populate title and body in notifications
- [x] Cancel notifications when alarm is off/deleted

### Alarm Response Screen
- [ ] Implement custom segment controller and table view to display the status of each invited member of the alarm
- [ ] Add toggle to allow users to opt in/out of the specific alarm
- [ ] ~~Drag on the screen to go back to previous screen~~ Determine most user-friendly segue to return to previous screen

### Share Alarms Screen
- [ ] Display list of contacts (method TBD)
- [ ] Implement alarm sharing functionality (method TBD)
- [ ] Back button to go back to previous screen

### Alarm Requests Screen
- [ ] Retrieve all incoming requests via API call to Firebase
- [ ] Click on each alarm to expand on the details of the alarm
- [ ] Implement accept/decline feature for each alarm
- [ ] Back button to go back to previous screen

### Profile/Settings Screen
- [x] Enable users to change pfp
- [x] Toggle for enabling/disabling snooze for all alarms
- [x] Toggle for enabling/disabling dark mode

### Contacts Screen
- [ ] Retrieve list of contacts from Firebase
- [ ] Add a new contact

### Friend Requests Screen
- [ ] Display all active friend requests
- [ ] Search for users through OAuth/Phone/Email


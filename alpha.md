# Alpha Release Checklist

## Main TODO

### Turn-in: code, readme

### Screens
- [ ] Loading (UI and functionality)
- [ ] Login (UI and functionality)
    - Redesign Login screen to have Create Account (small text) (remove Sign up screen)
- [ ] Home w/ Navigation bar - UI + functionality (nav bar leads to empty screens)
    - Display list of alarms using core data
- [ ] Alarm Creation - UI only + functionality
    - https://developer.apple.com/documentation/eventkit

## TODO Breakdown by Screen

### Login/Sign-up Screens
- [ ] Sign in using email
- [ ] Sign up using email
- [ ] Sign up using FB/Google
- [ ] Set up Firebase authentication

### Home Screen
- [ ] Set up table view for all alarms
- [ ] Set up tab view visually
- [ ] Click on the toggle by each alarm to turn on/off an alarm
- [ ] Click on the plus sign to create a new alarm on the Create/Edit Alarm screen

### Alarm Creation Screen
- [ ] Create Alarm entity in CoreData
- [ ] Options to specify time, date, sound, and recurring
- [ ] Click on the “save” button to finalize the newly created alarm and navigate back to the Home Screen
- [ ] Click on the “Back” button to go back to the previous screen
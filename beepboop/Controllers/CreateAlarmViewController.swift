//
//  CreateAlarmViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/27/21.
//

import UIKit
import CoreData
import Firebase

protocol ShareToListUpdater {
    func updateSharedToList(sharedToList: [String])
}

class CreateAlarmViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ShareToListUpdater{
    
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
    
    // MARK: - Properties
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var soundPickerView: UIPickerView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var snoozeLabel: UILabel!
    @IBOutlet weak var snoozeSwitch: UISwitch!
    
    private let sounds = ["beep", "boop", "birdsong", "nice alarm clock", "cheerful", "dramatic", "chopin's waterfall", "fur elise", "funny robot", "transformers", "attention", "toy toy toy", "ahaha", "i got a friend", "dancing android", "droid", "happy bday", "xmas carol"]
    private var recurring: String = "Never"
    private var soundSelected: String = "beep"
    
    private var sharedToList: [String] = []
    private let createAlarmToShareToFriendsSegueIdentifier = "CreateAlarmToShareToFriends"
    
    var delegate: UIViewController!
    var date: Date? = nil
    var alarmID: String = ""
    var currentUserUid: String?
    
    var groupAlarm: Bool = false
    var groupList: [String] = []
    var groupID: String = ""
    
    var userDocRef: DocumentReference!
    let alarmCollectionRef = Firestore.firestore().collection("alarmData")
    let userCollectionRef = Firestore.firestore().collection("userData")

    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        soundPickerView.delegate = self
        soundPickerView.dataSource = self
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {
            let alertController = UIAlertController(
                title: "Unknown error",
                message: "Something went wrong, please try again.",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        self.currentUserUid = currentUserUid
        self.userDocRef = userCollectionRef.document(currentUserUid)
        
        // Do any additional setup after loading the view.
        if(self.date != nil) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            let formattedDate = dateFormatter.string(from: self.date ?? Date())
            self.screenTitleLabel.text = "new alarm for \(formattedDate)"
            self.screenTitleLabel.font = UIFont(name: "JosefinSans-Regular", size: 32.0)
            self.datePicker.date = date ?? Date()
        } else {
            screenTitleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        }
        let aqua = UIColor(red: 0.24, green: 0.79, blue: 0.67, alpha: 1.00)
        let peach = UIColor(red: 0.99, green: 0.62, blue: 0.58, alpha: 1.00)
        let blue = UIColor(red:31/255, green:207/255, blue:245/255, alpha:1.0) // figma blue colour title
        
        datePicker.setValue(aqua, forKeyPath: "textColor")
        //        datePicker.setValue(true, forKey: "highlightsToday")
        timePicker.setValue(aqua, forKeyPath: "textColor")
        //        timePicker.setValue(true, forKey: "highlightsToday")
        
        screenTitleLabel.textColor = aqua
        timeLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        titleTextField.font = UIFont(name: "JosefinSans-Regular", size: 25.0)
        titleTextField.textColor = aqua
        dateLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        soundLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        snoozeLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleTextField.textColor = UIColor(red:31/255, green:207/255, blue:245/255, alpha:1.0) // figma blue colour title

        repeatButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatButton.setTitleColor(aqua, for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        shareButton.titleLabel?.textColor = aqua
        shareButton.setTitleColor(aqua, for: .normal)
        
        if alarmID != "" {
            userDocRef.collection("alarmMetadata").document(alarmID).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.snoozeSwitch.setOn(document.get("snooze") as? Bool ?? false, animated: false)
                }
            }
        } else {
            self.snoozeSwitch.setOn(false, animated: false)
        }

        self.snoozeSwitch.onTintColor = aqua
        self.snoozeSwitch.tintColor = aqua
        self.snoozeSwitch.thumbTintColor = UIColor.white
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:titleTextField.frame.height - 1), size: CGSize(width: titleTextField.frame.width, height:  1))
        bottomLine.backgroundColor = UIColor.black.cgColor
        titleTextField.borderStyle = UITextField.BorderStyle.none
        titleTextField.layer.addSublayer(bottomLine)
    
        if alarmID != "" {
            screenTitleLabel.text = "edit alarm"
            alarmCollectionRef.document(alarmID).getDocument { (alarmDoc, error) in
                guard let alarmDoc = alarmDoc, alarmDoc.exists else {
                    print("Could not find alarm \(String(describing: error))")
                    return
                }
                let alarmName = alarmDoc.get("name") as! String
                self.titleTextField.text = alarmName
                let recurrence = alarmDoc.get("recurrence") as! String
                self.repeatButton.setTitle(recurrence, for: .normal)
                self.recurring = recurrence
                let sound = alarmDoc.get("sound") as! String
                self.soundSelected = sound
                self.soundPickerView.selectRow(self.sounds.firstIndex(of: self.soundSelected) ?? 0, inComponent: 0, animated: false)
                self.pickerView(self.soundPickerView, didSelectRow: self.sounds.firstIndex(of: self.soundSelected) ?? 0, inComponent: 0)
                let time = alarmDoc.get("time") as! Timestamp
                let myDate = time.dateValue()
                self.datePicker.date = myDate
                self.timePicker.date = myDate
                let sharedList = alarmDoc.get("userList") as! [String]
                self.sharedToList = sharedList
                // TODO: set sound and snooze (not in Firestore right now)
            }
        }
        
        if self.groupAlarm {
            self.shareButton.isHidden = true
            self.sharedToList = groupList
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        var darkmode = false
        var textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                try fetchedResults = context.fetch(fetchRequest) as! [NSManagedObject]
                darkmode = fetchedResults[0].value(forKey: "darkmodeEnabled") as! Bool
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }

        if darkmode {
            self.view.backgroundColor = UIColor(rgb: 0x262221)
            overrideUserInterfaceStyle = .dark
            textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        }
        else {
            self.view.backgroundColor = UIColor(rgb: 0xFEFDEC)
            overrideUserInterfaceStyle = .light
            textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        }
        timeLabel.textColor = textColor
        dateLabel.textColor = textColor
        repeatLabel.textColor = textColor
        titleLabel.textColor = textColor
        repeatLabel.textColor = textColor
        soundLabel.textColor = textColor
        snoozeLabel.textColor = textColor

    }
    
    // set repeat occurrences in the form of an Alert Action Sheet
    @IBAction func repeatButtonPressed(_ sender: UIButton) {
        repeatButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        let attributedTitle = sender.attributedTitle(for: .normal)
        
        
        let alertController = UIAlertController(
            title: "Repeat",
            message: "Select repeating times for this alarm",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Hourly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Hourly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle("Hourly", for: .normal)
                                        self.recurring = "Hourly"
                                        print( "Hourly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Daily",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Daily", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Daily" , for: .normal )
                                        self.recurring = "Daily"
                                        print( "Daily")
                                    }))
        
        // TODO: consider adding selecting days of the week back in
        alertController.addAction(UIAlertAction(
                                    title: "Weekly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Weekly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Weekly" , for: .normal )
                                        self.recurring = "Weekly"
                                        print( "Weekly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Monthly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Monthly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Monthly" , for: .normal )
                                        self.recurring = "Monthly"
                                        print( "Monthly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Yearly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Yearly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Yearly" , for: .normal )
                                        
                                        self.recurring = "Yearly"
                                        print( "Yearly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Never",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Never", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Never" , for: .normal )
                                        self.recurring = "Never"
                                        print( "Never")
                                    }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Picker View functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sounds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sounds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.soundSelected = sounds[row] as String
     }
    
    // MARK: - Button actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        // add new alarm
        let snooze = self.snoozeSwitch.isOn
        if let time = self.timePicker?.date,
           let date = self.datePicker?.date,
           let mergedDate = self.combineDateWithTime(date: date, time: time),
           let title = self.titleTextField.text {
            if self.date != nil,
               let _ = self.delegate as? CalendarViewController {
                let calendarViewController = self.delegate as! AlarmAdder
                if alarmID != "" {
                    calendarViewController.updateAlarm(alarmID: alarmID, time: mergedDate, name: title, recurrence: recurring, sound: self.soundSelected, snooze: snooze, invitedUsers: self.sharedToList)
                } else {
                    calendarViewController.addAlarm(time: mergedDate, name: title, recurrence: recurring, sound: self.soundSelected, snooze: snooze, invitedUsers: self.sharedToList)
                }
                self.dismiss(animated: true, completion: nil)
            } else if let _ = self.delegate as? HomeViewController {
                let homeViewController = self.delegate as! AlarmAdder
                if alarmID != "" {
                    homeViewController.updateAlarm(alarmID: alarmID, time: mergedDate, name: title, recurrence: recurring, sound: self.soundSelected, snooze: snooze, invitedUsers: self.sharedToList)
                } else {
                    print("snooze value", snooze)
                    print("self.delegate as? HomeVC, sound: ", self.soundSelected)
                    homeViewController.addAlarm(time: mergedDate, name: title, recurrence: recurring, sound: self.soundSelected, snooze: snooze, invitedUsers: self.sharedToList)
                }
                self.dismiss(animated: true, completion: nil)
            } else if let _ = self.delegate as? GroupViewController {
                let groupViewController = self.delegate as! GroupAdder
                groupViewController.addAlarm(time: mergedDate, name: title, recurrence: recurring, sound: self.soundSelected, snooze: snooze, invitedUsers: self.sharedToList, groupID: self.groupID)
                self.dismiss(animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(
                    title: "Oops",
                    message: "We are not sure what went wrong. Please try again?",
                    preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(
                                            title: "Ok",
                                            style: .default,
                                            handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // transition to share to contacts popover/screen
        print("shareButtonPressed")
    }
    
    func updateSharedToList(sharedToList: [String]) {
        self.sharedToList = sharedToList
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.createAlarmToShareToFriendsSegueIdentifier,
           let destination = segue.destination as? ShareToFriendsViewController {
            destination.delegate = self
        }
    }
    
    // MARK: - Hide keyboard
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Utility
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateSelected = calendar.dateComponents([.year, .month, .day], from: date)
        let timeSelected = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateSelected.year
        mergedComponents.month = dateSelected.month
        mergedComponents.day = dateSelected.day
        mergedComponents.hour = timeSelected.hour
        mergedComponents.minute = timeSelected.minute
        mergedComponents.second = timeSelected.second
        
        return calendar.date(from: mergedComponents)
    }
}

extension UIViewController {
    
    func presentDetail(_ createAlarmViewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(createAlarmViewController, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

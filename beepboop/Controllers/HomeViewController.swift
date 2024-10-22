//
//  HomeViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/17/21.
//

import UIKit
import FirebaseCore
import Firebase
import CoreData

extension UIColor{
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

protocol AlarmAdder {
    func addAlarm(time: Date, name: String, recurrence: String, sound: String, snooze: Bool, invitedUsers: [String])
    func updateAlarm(alarmID: String, time: Date, name: String, recurrence: String, sound: String, snooze: Bool, invitedUsers: [String])
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmAdder{
    
    // MARK: - Properties
    var userDocRef: DocumentReference!
    var alarmCollectionRef: CollectionReference!
    var userCollectionRef: CollectionReference!
    var dataListener: ListenerRegistration! // Increases efficiency of app by only listening to data when view is on screen
    
    // data source of stored alarms per user
    var alarmList: [AlarmCustom] = []
    private var documents: [DocumentSnapshot] = []
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmTableView: UITableView!
    
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
    
    private let alarmTableViewCellIdentifier = "AlarmTableViewCell"
    private let homeToCreateAlarmSegueIdentifier = "HomeToCreateAlarm"
    
    var currentUserUid: String?
    var selectedAlarm: String?
    var darkmode: Bool = false
    var global_snooze: Bool = false
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load!")
        // Do any additional setup after loading the view.
        
        userCollectionRef = Firestore.firestore().collection("userData")
        
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
        
        alarmCollectionRef = Firestore.firestore().collection("alarmData")
        
        self.alarmTableView.delegate = self
        self.alarmTableView.dataSource = self
        self.alarmTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.alarmTableView.separatorColor = .clear
        
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
        // customize tab bar items
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "JosefinSans-Regular", size: 16)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.alarmTableView)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                try fetchedResults = context.fetch(fetchRequest) as! [NSManagedObject]
                global_snooze = fetchedResults[0].value(forKey: "snoozeEnabled") as! Bool
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

        }
        else {
            self.view.backgroundColor = UIColor(rgb: 0xFEFDEC)
            overrideUserInterfaceStyle = .light
        }
        self.updateAlarmsFirestore()
        self.alarmList.sort { $0.time! < $1.time!}
        self.alarmTableView.reloadData()
        
        for alarm in self.alarmList {
            alarmScheduler.setNotificationWithTimeAndDate(name: alarm.name!, time: alarm.time!, recurring: alarm.recurrence!, sound: alarm.sound!, uuidStr: alarm.uuid!)
        }
    }
    
    // load system supported fonts to determine system font labels
    func loadSystemSupportedFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName as String)
            print("Font Names = [\(names)]")
        }
    }
    
    // MARK: - Table View functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmTableViewCellIdentifier, for: indexPath as IndexPath) as! AlarmTableViewCell
        
        self.alarmList.sort { $0.time! < $1.time!}

        let alarm = alarmList[row]
        cell.alarmToggleSwitch?.tag = row
        
        populateCell(alarm: alarm, cell: cell)
        colourCell(cell: cell, row: row)
        colourSwitch(alarm: alarm, cell: cell)
        
        return cell
    }
    
    func colourSwitch(alarm: AlarmCustom, cell: AlarmTableViewCell) {
        let beepboopPink = UIColor(red: 0.97, green: 0.16, blue: 0.60, alpha: 1.00) // hex: #F82A99
        let beepboopBlue = UIColor(red: 0.04, green: 0.83, blue: 0.83, alpha: 1.00)
        
        cell.alarmToggleSwitch.onTintColor = beepboopBlue
        cell.alarmToggleSwitch.tintColor = beepboopBlue
        cell.alarmToggleSwitch.thumbTintColor = UIColor.white
//        cell.alarmToggleSwitch.backgroundColor = UIColor.blue
        cell.alarmToggleSwitch.layer.cornerRadius = 16
    }
    
    func colourCell(cell: AlarmTableViewCell, row: Int) {
        let pastelGreen = UIColor(red: 0.58, green: 0.92, blue: 0.78, alpha: 1.00) // hex: #95EBC8
        let lightGreen = UIColor(red: 0.69, green: 1.00, blue: 0.74, alpha: 1.00) // hex: #AFFFBC
        let softYellow = UIColor(red: 0.98, green: 1.00, blue: 0.69, alpha: 1.00) // hex: #F9FFAF
        let orangeGold = UIColor(red: 1.00, green: 0.83, blue: 0.52, alpha: 1.00) // hex: #FFD385
        let rose = UIColor(red: 1.00, green: 0.70, blue: 0.70, alpha: 1.00) // hex: #FFB3B3
        let babyPink = UIColor(red: 1.00, green: 0.79, blue: 0.81, alpha: 1.00) // hex: #FFC9CE
        let lilac = UIColor(red: 1.00, green: 0.75, blue: 0.96, alpha: 1.00) // hex: #FEBEF6
        let lavender = UIColor(red: 0.83, green: 0.82, blue: 1.00, alpha: 1.00) // hex: #D3D1FF
        let doveEggBlue = UIColor(red: 0.76, green: 0.87, blue: 1.00, alpha: 1.00) // hex: #C1DDFF
        let tiffanyBlue = UIColor(red: 0.67, green: 0.95, blue: 1.00, alpha: 1.00) // hex: #ABF1FF
        
        let cellColours = [pastelGreen, lightGreen, softYellow, orangeGold, rose, babyPink, lilac, lavender, doveEggBlue, tiffanyBlue]
        let frequency = row % cellColours.count
        cell.contentView.backgroundColor = cellColours[frequency]
    }
    
    func populateCell(alarm: AlarmCustom, cell: AlarmTableViewCell) {
        print("in populateCell, alarm=\(alarm)")
        cell.alarmNameLabel?.text = alarm.name
        cell.alarmNameLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        cell.alarmTimeLabel?.text = self.extractTimeFromDate(time: alarm.time)
        cell.alarmTimeLabel.font = UIFont(name: "JosefinSans-Regular", size: 25.0)
        cell.alarmDateLabel?.text = self.extractDate(time: alarm.time)
        cell.alarmDateLabel.font = UIFont(name: "JosefinSans-Regular", size: 15.0)
        cell.alarmImageView?.image = UIImage(named: "icons8-iceberg-50")
        if global_snooze {
            cell.alarmToggleSwitch.setOn(false, animated: false)
        }
        else {
            var on = true
            userDocRef.collection("alarmMetadata").document(alarm.uuid!).getDocument { (document, error) in
                if let document = document, document.exists {
                    on = document.get("enabled") as? Bool ?? true
                    cell.alarmToggleSwitch.setOn(on, animated: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            print("Just Swiped Edit", action)
            completion(true)
            self.performSegue(withIdentifier: self.homeToCreateAlarmSegueIdentifier, sender: indexPath)
        }
        edit.backgroundColor = UIColor(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 0)
//        edit.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image {
//            _ in UIImage(named: "EditIcon")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
//        }
        edit.image = UIImage(named: "EditIcon")

        let responses = UIContextualAction(style: .normal, title: "Responses") { (action, view, completion) in
            print("Just Swiped Responses", action)
            self.performSegue(withIdentifier: "HomeToAlarmMetadata", sender: indexPath)
            completion(true)
        }
        responses.backgroundColor = UIColor(red: 0.5725490451, green: 0.2313725501, blue: 0, alpha: 0)
        responses.image = UIImage(named: "ResponseIcon")
//        responses.image = UIGraphicsImageRenderer(size: CGSize(width: 90, height: 90)).image {
//            _ in UIImage(named: "ResponseIcon")?.draw(in: CGRect(x: 0, y: 0, width: 90, height: 90))
//        }

        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            print("Just Swiped Deleted", action)
            if let uuid = self.alarmList[indexPath.row].uuid,
               let currentUserUid = self.currentUserUid {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
                // alert asking for complete removal of alarm and not just user id from alarm (if owner of alarm)
                // add owner uid for each alarm in create alarm
                self.userDocRef.collection("alarmMetadata").document(uuid).delete()
                self.alarmCollectionRef.document(uuid).updateData([
                    "userStatus": FieldValue.arrayRemove([currentUserUid]),
                    "userList": FieldValue.arrayRemove([currentUserUid])
                ])

//                self.updateAlarmsFirestore()
                // TODO: remove alarm data from collection if userStatus is empty
            }

            self.alarmList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completion(false)
        }
        delete.image = UIImage(named: "DeleteIcon")
//        delete.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image {
//            _ in UIImage(named: "DeleteIcon")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
//        }
        delete.backgroundColor =  UIColor(red: 0.2436070212, green: 0.5393256153, blue: 0.1766586084, alpha: 0)

        let config = UISwipeActionsConfiguration(actions: [delete, responses, edit])
        config.performsFirstActionWithFullSwipe = false

        return config
   }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        guard let uuidStr = self.alarmList[index].uuid else {
            print("Something went wrong when getting uuid for the alarm")
            abort()
        }
        
        self.userDocRef.collection("alarmMetadata").document(uuidStr).updateData(["enabled": sender.isOn, "snooze": !sender.isOn])
        
        // Enable/Disable notifications
        let alarm = self.alarmList[index]
        if sender.isOn {
            if global_snooze {
                sender.setOn(false, animated: true)
                return
            }
            if let name = alarm.name,
               let time = alarm.time,
               let recurring = alarm.recurrence,
               let sound = alarm.sound,
               let uuid = alarm.uuid {
                alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurring, sound: sound, uuidStr: uuid)
                }
        } else {
            if let uuid = alarm.uuid {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
            }
        }
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// set animation variables
        let duration = 0.5
        let delayFactor = 0.05
        let rowHeight: CGFloat = 62
        
        /// fades the cell by setting alpha as zero and moves the cell downwards, then animates the cell's alpha and returns it to it's original position based on indexPaths
        cell.transform = CGAffineTransform(translationX: 0, y: rowHeight * 1.4)
        cell.alpha = 0
        UIView.animate(
            withDuration: duration,
            delay: delayFactor * Double(indexPath.row),
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
        })
        
        /// moves the cell downwards, then animates the cell's by returning them to their original position with spring bounce based on indexPaths
        cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
        UIView.animate(
            withDuration: duration,
            delay: delayFactor * Double(indexPath.row),
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.1,
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    // MARK: - Delegate functions
    
    func addAlarm(time: Date, name: String, recurrence: String, sound: String, snooze: Bool, invitedUsers: [String]) {
        self.addAlarmToFirestore(time: time, name: name, recurrence: recurrence, sound: sound, snooze: snooze, invitedUsers: invitedUsers)
//        self.updateAlarmsFirestore()
    }
    
    // MARK: - Firestore functions
    
    func addAlarmToFirestore(time: Date, name: String, recurrence: String, sound: String, snooze: Bool, invitedUsers: [String]) {
        guard let currentUserUid = self.currentUserUid else {
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
        
        
        let uuid = UUID()
        let userStatus = self.getStatusForUsers(invitedUsers: invitedUsers)
        let userCollectionRef = Firestore.firestore().collection("userData")
        let newAlarm = AlarmCustom(name: name, time: time, recurrence: recurrence, sound: sound, uuid: uuid.uuidString, userList: [currentUserUid] + invitedUsers, userStatus: userStatus)
        
        alarmCollectionRef.document(uuid.uuidString).setData(newAlarm.dictionary)
        userDocRef.collection("alarmMetadata").document(uuid.uuidString).setData(["snooze": snooze, "enabled": !snooze])
        userDocRef.updateData([
            "alarmRequestsSent": FieldValue.arrayUnion([uuid.uuidString])
        ])
        
        for user in invitedUsers {
            userCollectionRef.document(user).updateData([
                "alarmRequestsReceived": FieldValue.arrayUnion([uuid.uuidString])
            ])
        }
        if !global_snooze && !snooze {
            alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurrence, sound: sound, uuidStr: uuid.uuidString)
        }
        self.alarmList.append(newAlarm)
        self.alarmTableView.reloadData()
    }
    
    func updateAlarm(alarmID: String, time: Date, name: String, recurrence: String, sound: String, snooze: Bool, invitedUsers: [String]) {
        alarmCollectionRef.document(alarmID).updateData([
            "time": time,
            "name": name,
            "recurrence": recurrence,
            "sound": sound,
            "userList": invitedUsers
        ])
        userDocRef.collection("alarmMetadata").document(alarmID).setData(["snooze": snooze, "enabled": !snooze])
        self.updateAlarmsFirestore()
        
        if !global_snooze {
            alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurrence, sound: sound, uuidStr: alarmID)
        }
    }
    
    func getStatusForUsers(invitedUsers: [String]) -> [String: String] {
        var userStatuses = [String: String]()
        userStatuses[self.currentUserUid!] = "Accepted"
        for user in invitedUsers {
            userStatuses[user] = "Pending"
        }
        return userStatuses
        
    }
    
    func updateAlarmsFirestore() {
        self.alarmList = [AlarmCustom]()
        var alarmUuids = [String]()
        userDocRef.collection("alarmMetadata").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    alarmUuids.append(document.documentID)
                }
                
                for alarmUuid in alarmUuids {
                    let docRef = self.alarmCollectionRef.document(alarmUuid)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            if let model = AlarmCustom(dictionary: document.data()!) {
                                self.alarmList.append(model)
                                self.alarmTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    // Increases efficiency of app by only listening to data when view is on screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let dataListener = self.dataListener {
            dataListener.remove()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToAlarmMetadata", let destination = segue.destination as? AlarmMetadataViewController {
            if let alarmID = selectedAlarm { // From notifications
                // If we're getting a notification, the alarm must be enabled.
                destination.alarmID = alarmID
            } else if let indexPath = sender as? IndexPath {
                // If we're coming from home table view, the alarm may not be enabled.
                let uuid = self.alarmList[indexPath.row].uuid!
                destination.alarmID = uuid
                destination.userID = currentUserUid!
                destination.global_snooze = self.global_snooze
            }
        } else if segue.identifier == self.homeToCreateAlarmSegueIdentifier,
           let destination = segue.destination as? CreateAlarmViewController {
            destination.delegate = self
            
            if let indexPath = sender as? IndexPath {
                destination.alarmID = self.alarmList[indexPath.row].uuid!
            }
        } else if segue.identifier == "HomeToAlarmDisplayIdentifier", let destination = segue.destination as? AlarmDisplayViewController {
            if let alarmID = selectedAlarm { // From notifications
                destination.alarmID = alarmID
            }
        }
    }
    
    // MARK: - Utility
    func extractTimeFromDate(time: Date?) -> String {
        if let time = time {
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: time)
            let minutes = calendar.component(.minute, from: time)
            if hour >= 12 {
                if hour > 12 {
                    hour -= 12
                }
                return String(format: "%d:%0.2d PM", hour, minutes)
            } else {
                if hour == 0 {
                    hour = 12
                }
                return String(format: "%d:%0.2d AM", hour, minutes)
            }
        } else {
            return "Error when extracting time from Date object"
        }
    }
    
    func extractDate(time: Date?) -> String {
        if let time = time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, MMM d"
            return dateFormatter.string(from: time)
        } else {
            return "Error when extracting date from Date object"
        }
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
}


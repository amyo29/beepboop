//
//  HomeViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/17/21.
//

import UIKit
import FirebaseCore
import Firebase

protocol AlarmAdder {
    func addAlarm(time: Date, name: String, recurrence: String)
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmAdder{
    
    // MARK: - Properties
    var userDocRef: DocumentReference!
    var alarmCollectionRef: CollectionReference!    
    var dataListener: ListenerRegistration! // Increases efficiency of app by only listening to data when view is on screen
    
    // data source of stored alarms per user
    private var alarmList: [AlarmCustom] = []
    private var documents: [DocumentSnapshot] = []
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmTableView: UITableView!
    
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
    
    private let alarmTableViewCellIdentifier = "AlarmTableViewCell"
    
    var currentUserUid: String?
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let userCollectionRef = Firestore.firestore().collection("userData")
        
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
        let attributes = [NSAttributedString.Key.font:UIFont(name: "JosefinSans-Regular", size: 20)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.alarmTableView)
        self.alarmList = [AlarmCustom]()
        self.updateAlarmsFirestore()
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
        print("In tableView count method, count: ", self.alarmList.count)
        return self.alarmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In tableView cell render method, count: ", self.alarmList.count)
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmTableViewCellIdentifier, for: indexPath as IndexPath) as! AlarmTableViewCell
        
        let alarm = alarmList[row]
        cell.alarmToggleSwitch?.tag = row
        populateCell(alarm: alarm, cell: cell)
        
        return cell
    }
    
    func populateCell(alarm: AlarmCustom, cell: AlarmTableViewCell) {
        print("in populateCell, alarm=\(alarm)")
        cell.alarmNameLabel?.text = alarm.name
        cell.alarmTimeLabel?.text = self.extractTimeFromDate(time: alarm.time)
        cell.alarmDateLabel?.text = self.extractDate(time: alarm.time)
        cell.alarmImageView?.image = UIImage(named: "EventPic")
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    // Remove alarm from table view by swiping to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete notifications
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
            
            alarmList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.reloadData()
        }
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        guard let uuidStr = self.alarmList[index].uuid else {
            print("Something went wrong when getting uuid for the alarm")
            abort()
        }
        
        self.userDocRef.collection("alarmMetadata").document(uuidStr).updateData(["enabled": sender.isOn])
        
        // Enable/Disable notifications
        let alarm = self.alarmList[index]
        if sender.isOn {
            if let name = alarm.name,
               let time = alarm.time,
               let recurring = alarm.recurrence,
               let uuid = alarm.uuid {
                alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurring, uuidStr: uuid)
            }
        } else {
            if let uuid = alarm.uuid {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
            }
        }
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: AlarmTableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Delegate functions
    
    func addAlarm(time: Date, name: String, recurrence: String) {
        self.addAlarmToFirestore(time: time, name: name, recurrence: recurrence)
//        self.updateAlarmsFirestore()
    }
    
    // MARK: - Firestore functions
    
    func addAlarmToFirestore(time: Date, name: String, recurrence: String) {
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
        let newAlarm = AlarmCustom(name: name, time: time, recurrence: recurrence, uuid: uuid.uuidString, userList: [currentUserUid], userStatus: [currentUserUid: "Accepted"])
        
        alarmCollectionRef.document(uuid.uuidString).setData(newAlarm.dictionary)
        userDocRef.collection("alarmMetadata").document(uuid.uuidString).setData(["snooze": false, "enabled": true])
        alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurrence, uuidStr: uuid.uuidString)
        self.alarmList.append(newAlarm)
        self.alarmTableView.reloadData()
    }
    
    // TODO: no current logic to completely delete an alarmData document from Firestore
    
    // Function for Testing purposes: Updates Firestore data manually
//    func retrieveDataFromFirestore() {
//        docRef.getDocument { (docSnapshot, error) in
//            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
//            let myData = docSnapshot.data()
//            let latestAlarm = myData?["name"] as? String ?? "(none)"
//            print(latestAlarm)
//        }
//    }
    
    // Updates Firestore data in real-time via snapshot listener
    // Updates Table view as soon as users create/edit alarm w/o needing to manually fetch data from firestore (see retrieveDataFromFirestore() code)
    
    // 2 approaches to update alarms
    // Approach 1 (slower): alarmData collection -> userList -> filter docs with userStatus field dict with value "Accepted"
    // Approach 2 (faster): userData collection -> alarmList -> find alarm in alarmData collection
    
//    func updateAlarmsFirestore() {
//        if let currentUserUid = self.currentUserUid {
//            dataListener = alarmCollectionRef.whereField("userList", arrayContains: currentUserUid).addSnapshotListener { [unowned self] (snapshot, error) in
//                guard let snapshot = snapshot else {
//                    print("Error fetching snapshot results: \(error!)")
//                    return
//                }
//
//                let filteredDocuments = snapshot.documents.filter { (document) in
//                    // TODO: we might be able to simplify the logic here
//                    if let model = AlarmCustom(dictionary: document.data()) {
//                        if let userStatuses = model.dictionary["userStatus"] as? [String: String],
//                           let userStatus = userStatuses[currentUserUid],
//                           userStatus == "Accepted" {
//                            return true
//                        } else {
//                            return false
//                        }
//                    } else {
//                        print(document.data())
//                        // Don't use fatalError here in a real app.
//                        fatalError("Unable to initialize type \(AlarmCustom.self) with dictionary \(document.data())")
//                    }
//                }
//
//                let models = filteredDocuments.map { (document) -> AlarmCustom in
//                    if let model = AlarmCustom(dictionary: document.data()) {
//                        return model
//                    } else {
//                        print(document.data())
//                        // Don't use fatalError here in a real app.
//                        fatalError("Unable to initialize type \(AlarmCustom.self) with dictionary \(document.data())")
//                    }
//                }
//
//                self.alarmList = models
//                self.documents = snapshot.documents
//
//                self.alarmTableView?.reloadData()
//            }
//        }
//    }
    
    func updateAlarmsFirestore() {
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

//                if alarmUuids.count > 0 {
//                    self.dataListener = self.alarmCollectionRef.whereField("uuid", in: alarmUuids).addSnapshotListener { [unowned self] (snapshot, error) in
//                        guard let snapshot = snapshot else {
//                            print("Error fetching snapshot results: \(error!)")
//                            return
//                        }
//
//                        var models = snapshot.documents.map { (document) -> AlarmCustom in
//                            if let model = AlarmCustom(dictionary: document.data()) {
//                                return model
//                            } else {
//                                print(document.data())
//                                // Don't use fatalError here in a real app.
//                                fatalError("Unable to initialize type \(AlarmCustom.self) with dictionary \(document.data())")
//                            }
//                        }
//
//                        self.alarmList = models
//                        self.documents = snapshot.documents
//
//                        self.alarmTableView?.reloadData()
//                    }
//                }
            }
        }
    }
    
//    func updateAlarmsFirestore() {
//        var alarmUuids = [String]()
//        userDocRef.collection("alarmMetadata").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    alarmUuids.append(document.documentID)
//                }
//
//                if alarmUuids.count > 0 {
//                    self.dataListener = self.alarmCollectionRef.whereField("uuid", in: alarmUuids).addSnapshotListener { [unowned self] (snapshot, error) in
//                        guard let snapshot = snapshot else {
//                            print("Error fetching snapshot results: \(error!)")
//                            return
//                        }
//
//                        var models = snapshot.documents.map { (document) -> AlarmCustom in
//                            if let model = AlarmCustom(dictionary: document.data()) {
//                                return model
//                            } else {
//                                print(document.data())
//                                // Don't use fatalError here in a real app.
//                                fatalError("Unable to initialize type \(AlarmCustom.self) with dictionary \(document.data())")
//                            }
//                        }
//
//                        self.alarmList = models
//                        self.documents = snapshot.documents
//
//                        self.alarmTableView?.reloadData()
//                    }
//                }

//            }
//        }
//    }
    
    // Increases efficiency of app by only listening to data when view is on screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let dataListener = self.dataListener {
            dataListener.remove()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateAlarmViewController{
            destination.delegate = self
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
}


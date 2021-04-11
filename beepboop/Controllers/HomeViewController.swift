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
    
    var userID: String?
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Firestore.firestore().collection("userData").whereField("userId", isEqualTo: self.userID!).getDocuments(
            completion:
            { (snapshot, error) in
                if let error = error {
                    print("An error occurred when retrieving the user: \(error.localizedDescription)")
                } else if snapshot!.documents.count != 1 {
                    print("The specified user with UUID \(self.userID!) does not exist.")
                } else {
                    self.userDocRef = snapshot?.documents.first?.reference
                }
            }
        )
        
        alarmCollectionRef = Firestore.firestore().collection("alarmData")
        
        // read from firestore
        //        let db = Firestore.firestore()
        //        db.collection("alarms").getDocuments() { (querySnapshot, error) in
        //            if let error = error {
        //                print("Error getting documents: \(error)")
        //            } else {
        //                for document in querySnapshot!.documents {
        //                    print("\(document.documentID) => \(document.data())")
        //                }
        //            }
        //        }
        
        self.alarmTableView.delegate = self
        self.alarmTableView.dataSource = self
        
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
        // customize tab bar items
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "JosefinSans-Regular", size: 20)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: [])
        
        // loadSystemSupportedFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.alarmTableView)
        self.updateAlarmsFirestore()
        
        //        print("alarms count: ", self.alarms.count)
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
    }
    
    // Remove alarm from table view by swiping to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete notifications
            if let uuid = self.alarmList[indexPath.row].uuidStr {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
                
                
                alarmCollectionRef.whereField("uuid", isEqualTo: uuid).getDocuments(completion: { (snapshot, error) in
                                                                                        if let error = error {
                                                                                            print(error.localizedDescription)
                                                                                        } else {
                                                                                            for document in snapshot!.documents {
                                                                                                document.reference.delete()
                                                                                            }
                                                                                        }})
                
                
                
                
            }
            
            
            alarmList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        
        alarmCollectionRef.whereField("uuid", isEqualTo: self.alarmList[index].uuidStr!).getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print("An error occurred when retrieving alarmData: \(error.localizedDescription)")
            } else if snapshot!.documents.count != 1 {
                print("The specified alarm with UUID \(self.alarmList[index].uuidStr!) does not exist.")
            } else {
                let document = snapshot?.documents.first
                document?.reference.updateData([
                    "enabled": sender.isOn
                ])
            }
        }
        )
        
        // Enable/Disable notifications
        let alarm = self.alarmList[index]
        if sender.isOn {
            if let name = alarm.name,
               let time = alarm.time,
               let recurring = alarm.recurrence,
               let uuid = alarm.uuidStr {
                alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurring, uuidStr: uuid)
            }
        } else {
            if let uuid = alarm.uuidStr {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
            }
        }
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: AlarmTableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        
        // add shadow on cell
        cell.backgroundColor = .clear // very important
        cell.contentView.layer.masksToBounds = false
        cell.contentView.layer.shadowOpacity = 0.23
        cell.contentView.layer.shadowRadius = 4
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.contentView.layer.shadowColor = UIColor.black.cgColor
        
        // add corner radius on `contentView`
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 8
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    // MARK: - Delegate functions
    
    func addAlarm(time: Date, name: String, recurrence: String) {
        self.addAlarmToFirestore(time: time, name: name, recurrence: recurrence)
        self.updateAlarmsFirestore()
    }
    
    // MARK: - Firestore functions
    
    func addAlarmToFirestore(time: Date, name: String, recurrence: String) {
        let uuid = UUID()
        let newAlarm = AlarmCustom(name: name, time: time, recurrence: recurrence, uuidStr:uuid.uuidString, userId: [self.userID!])
        
        alarmCollectionRef.addDocument(data: newAlarm.dictionary)
        userDocRef.updateData([
            "alarmData": FieldValue.arrayUnion([["alarmId": uuid.uuidString, "snooze": false, "enabled": true]])
        ])
        alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurrence, uuidStr: uuid.uuidString)
    }
    
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
    func updateAlarmsFirestore() {
        dataListener = alarmCollectionRef.whereField("userId", arrayContains: self.userID!).addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> AlarmCustom in
                if let model = AlarmCustom(dictionary: document.data()) {
                    return model
                } else {
                    print(document.data())
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(AlarmCustom.self) with dictionary \(document.data())")
                }
            }
            self.alarmList = models
            self.documents = snapshot.documents
            
            self.alarmTableView?.reloadData()
        }
    }
    
    // Increases efficiency of app by only listening to data when view is on screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataListener.remove()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateAlarmViewController{
            destination.delegate = self
        }
        
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
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


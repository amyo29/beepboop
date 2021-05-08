//
//  GroupMetadataViewController.swift
//  beepboop
//
//  Created by Sanjana K on 5/7/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore
import CoreData

class GroupMetadataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupPic: UIButton!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var metaTableView: UITableView!
    
    private var tableViewList: [Any] = []
    private var alarmList: [AlarmCustom] = []
    private var memberList: [UserCustom] = []
    private var alarms = true
    private let alarmTableViewCellIdentifier = "AlarmTableViewCell"
    private let memberTableViewCellIdentifier = "FriendsTableViewCell"
    
    let alarmCollectionRef = Firestore.firestore().collection("alarmData")
    let userCollectionRef = Firestore.firestore().collection("userData")
    
    var group: GroupCustom? = nil
    var delegate: UIViewController!
    var global_snooze: Bool = false
    var currentUserUid: String?
    var curUserDocRef: DocumentReference!
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metaTableView.delegate = self
        self.metaTableView.dataSource = self
        self.metaTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.metaTableView.separatorColor = .clear

        self.groupLabel.text = group?.name
        self.groupLabel.font = UIFont(name: "JosefinSans-Regular", size: 30)
        self.alarmButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20)
        self.memberButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20)
        
        // populate alarmList
        for alarmUuid in group?.alarms ?? [] {
            let alarmDocRef = self.alarmCollectionRef.document(alarmUuid)
            alarmDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let model = AlarmCustom(dictionary: document.data()!) {
                        self.alarmList.append(model)
                        self.metaTableView.reloadData()
                    }
                }
            }
        }
        
        // populate memberList
        for userUuid in group?.members ?? [] {
            let userDocRef = self.userCollectionRef.document(userUuid)
            userDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let model = UserCustom(dictionary: document.data()!) {
                        self.memberList.append(model)
                    }
                }
            }
        }
        
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
        self.curUserDocRef = self.userCollectionRef.document(self.currentUserUid!)
        
        if group?.photoURL != nil && group?.photoURL != "" {
            self.loadData(url: URL(string: group?.photoURL as! String)!) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.groupPic.setBackgroundImage(UIImage(data: data)?.circleMasked, for: .normal)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.metaTableView)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        var darkmode = false
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.alarms {
            return self.alarmList.count
        } else {
            return self.memberList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Our table view should be AlarmTableViewCells
        if self.alarms {
            let row = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmTableViewCellIdentifier, for: indexPath as IndexPath) as! AlarmTableViewCell
            
            self.alarmList.sort { $0.time! < $1.time!}

            let alarm = self.alarmList[row]
            cell.alarmToggleSwitch?.tag = row
            
            populateCellAlarm(alarm: alarm, cell: cell)
            colourCell(cell: cell, row: row)
            colourSwitch(alarm: alarm, cell: cell)
            
            return cell
        } else {
            let row = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: self.memberTableViewCellIdentifier, for: indexPath as IndexPath) as! FriendsTableViewCell

            let member = self.memberList[row]

            populateCellMember(member: member, cell: cell)
            colourCell(cell: cell, row: row)

            return cell
        }
    }
    
    func colourSwitch(alarm: AlarmCustom, cell: AlarmTableViewCell) {
        let beepboopPink = UIColor(red: 0.97, green: 0.16, blue: 0.60, alpha: 1.00) // hex: #F82A99
        let beepboopBlue = UIColor(red: 0.04, green: 0.83, blue: 0.83, alpha: 1.00)
        
        cell.alarmToggleSwitch.onTintColor = beepboopBlue
        cell.alarmToggleSwitch.tintColor = beepboopBlue
        cell.alarmToggleSwitch.thumbTintColor = UIColor.white
        cell.alarmToggleSwitch.layer.cornerRadius = 16
    }
    
    func colourCell(cell: UITableViewCell, row: Int) {
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
    
    func populateCellAlarm(alarm: AlarmCustom, cell: AlarmTableViewCell) {
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

            self.curUserDocRef.collection("alarmMetadata").document(alarm.uuid!).getDocument { (document, error) in
                if let document = document, document.exists {
                    on = document.get("enabled") as? Bool ?? true
                    cell.alarmToggleSwitch.setOn(on, animated: false)
                }
            }
        }
    }
    
    func populateCellMember(member: UserCustom, cell: FriendsTableViewCell) {
        cell.friendNameLabel?.text = member.name
        cell.friendNameLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        
        if member.photoURL == nil || member.photoURL == "" {
            cell.friendImageView?.image = UIImage(named: "EventPic") // Default
        } else {
            self.loadData(url: URL(string: member.photoURL as! String)!) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    cell.friendImageView?.image = UIImage(data: data)?.circleMasked
                }
            }
        }

        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
        cell.friendMetadataButton.isHidden = true
    }
    
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        guard let uuidStr = self.alarmList[index].uuid else {
            print("Something went wrong when getting uuid for the alarm")
            abort()
        }
        
        self.curUserDocRef.collection("alarmMetadata").document(uuidStr).updateData(["enabled": sender.isOn, "snooze": !sender.isOn])
        
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
    
    @IBAction func onAlarmsClick(_ sender: Any) {
        // UI: set new alphas for each button
        self.alarmButton.alpha = 1
        self.memberButton.alpha = 0.5
        
        self.tableViewList = self.alarmList
        self.alarms = true
        
        self.metaTableView.reloadData()
    }
    
    @IBAction func onMembersClick(_ sender: Any) {
        // UI: set new alphas for each button
        self.alarmButton.alpha = 0.5
        self.memberButton.alpha = 1
        
        self.tableViewList = self.memberList
        self.alarms = false
        
        self.metaTableView.reloadData()
    }
    
    @IBAction func onBackClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

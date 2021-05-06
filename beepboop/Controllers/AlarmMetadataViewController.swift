//
//  AlarmMetadataViewController.swift
//  beepboop
//
//  Created by Sanjana K on 4/13/21.
//

import UIKit
import Firebase
import CoreData


enum StatusMode {
    case accepted
    case declined
    case pending
}

class AlarmMetadataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var declinedButton: UIButton!
    @IBOutlet weak var declinedLabel: UILabel!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var responseTableView: UITableView!
    @IBOutlet weak var responsesLabel: UILabel!
    @IBOutlet weak var enableToggle: UISwitch!
    
    let alarmCollectionRef = Firestore.firestore().collection("alarmData")
    let userCollectionRef = Firestore.firestore().collection("userData")
    private let responsesTableViewCellIdentifier = "ResponseTableViewCell"
    private var nameList: [Dictionary<String, Any>] = []
    private let acceptIcon = UIImage(named: "AcceptIcon")
    private let declinedIcon = UIImage(named: "DeclineIcon")
    private var curIcon = UIImage(named: "AcceptIcon")
    var acceptedList: [Dictionary<String, Any>] = []
    var declinedList: [Dictionary<String, Any>] = []
    var pendingList: [Dictionary<String, Any>] = []
    
    var status: StatusMode = .accepted
    
    var alarmID: String = ""
    var enabled: Bool = true
    var userID: String = ""
    var time: String = ""
    var timestampTime: Timestamp = Timestamp()
    var alarmName: String = "iOS Class"
    var recurring: String = ""
    var global_snooze: Bool = false
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in metadata controller")
        self.responseTableView.delegate = self
        self.responseTableView.dataSource = self
        
        self.responseTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.responseTableView.separatorColor = .clear
        let aqua = UIColor(red: 0.24, green: 0.79, blue: 0.67, alpha: 1.00)
        self.enableToggle.onTintColor = aqua
        
        declinedButton.imageView?.alpha = 0.5
        declinedLabel.alpha = 0.5
        pendingButton.imageView?.alpha = 0.5
        pendingLabel.alpha = 0.5

        if userID != "" {
            let userDocRef = userCollectionRef.document(userID)
            userDocRef.collection("alarmMetadata").document(alarmID).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.enabled = document.get("enabled") as? Bool ?? true
                    self.enableToggle.setOn(self.enabled, animated: false)
                }
            }
        } else {
            self.enableToggle.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.responseTableView)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        var darkmode = false
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

        }
        else {
            self.view.backgroundColor = UIColor(rgb: 0xFEFDEC)
            overrideUserInterfaceStyle = .light
        }
        self.updateStatuses()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.responsesTableViewCellIdentifier, for: indexPath as IndexPath) as! ResponsesTableViewCell
        if nameList.count > 0 {
            print(nameList)
            cell.friendName.text = String(describing: nameList[row]["name"]!)
            cell.friendName.font = UIFont(name: "JosefinSans-Regular", size: 25)
            cell.friendProfileImage?.image = UIImage(named: "EventPic")
            let photoURL = nameList[row]["photoURL"]
            if photoURL == nil || photoURL as! String == "" {
                cell.friendProfileImage?.image = UIImage(named: "EventPic") // Default
                
            } else {
                self.loadData(url: URL(string: photoURL as! String)!) { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        cell.friendProfileImage?.image = UIImage(data: data)?.circleMasked
                    }
                }
            }
            cell.friendStatusImage?.image = curIcon
        }
        
        cell.backgroundColor = UIColor(hex: "FEFDEC")
        
        switch status {
        case .accepted:
            cell.contentView.backgroundColor = UIColor(red: 0.58, green: 0.92, blue: 0.78, alpha: 1.00) // hex: #95EBC8, pastel green
        case .declined:
            cell.contentView.backgroundColor = UIColor(red: 1.00, green: 0.70, blue: 0.70, alpha: 1.00) // hex: #FFB3B3, rose
        case .pending:
            cell.contentView.backgroundColor = UIColor(red: 0.98, green: 1.00, blue: 0.69, alpha: 1.00) // hex: #F9FFAF, soft yellow
        }
        
        return cell
    }
    
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // Necessary for popping up from notifications, since there's no NavController and the segue relies on data loading from the HomeViewController.
    func updateStatuses() {
        if alarmID != "" {
            print("Finding \(alarmID)")
            let getResponses = DispatchGroup() // Keeps track of async forloop
            alarmCollectionRef.document(alarmID).getDocument { (alarmDoc, error) in
                guard let alarmDoc = alarmDoc, alarmDoc.exists else {
                    print("Could not find alarm \(String(describing: error))")
                    return
                }
                let responses = alarmDoc.get("userStatus") as! Dictionary<String, String>
                for (uuid, response) in responses {
                    getResponses.enter()
                    self.userCollectionRef.document(uuid).getDocument { (userDoc, error) in
                        if let userDoc = userDoc, userDoc.exists, let data = userDoc.data() {
                            switch response {
                            case "Accepted":
                                self.acceptedList.append(data)
                                break
                            case "Denied":
                                self.declinedList.append(data)
                                break
                            case "Pending":
                                self.pendingList.append(data)
                                break
                            default:
                                print("Response value invalid: \(response)")
                            }
                        }
                        else {
                            print("Could not find user \(uuid)")
                        }
                        getResponses.leave()
                    }
                }
                getResponses.notify(queue: .main) {
                    self.timestampTime = alarmDoc.get("time") as! Timestamp
                    self.time = self.extractTimeFromDate(time: self.timestampTime)
                    self.alarmName = alarmDoc.get("name") as! String
                    self.responsesLabel.font = UIFont(name: "JosefinSans-Regular", size: 40)
                    self.nameList = self.acceptedList
                    self.acceptedLabel.text = "Confirmed (\(self.acceptedList.count))"
                    self.acceptedLabel.font = UIFont(name: "JosefinSans-Regular", size: 17)
                    self.declinedLabel.text = "Declined (\(self.declinedList.count))"
                    self.declinedLabel.font = UIFont(name: "JosefinSans-Regular", size: 17)
                    self.pendingLabel.text = "Pending (\(self.pendingList.count))"
                    self.pendingLabel.font = UIFont(name: "JosefinSans-Regular", size: 17)
                    self.responseTableView.reloadData()
                    self.timeLabel.text = self.time
                    self.timeLabel.font = UIFont(name: "JosefinSans-Regular", size: 50)
                    self.alarmNameLabel.text = self.alarmName
                    self.alarmNameLabel.font = UIFont(name: "JosefinSans-Regular", size: 35)
                    self.recurring = alarmDoc.get("recurrence") as! String
                }
            }
        }
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        if userID != "" {
            let userDocRef = userCollectionRef.document(userID)
            userDocRef.collection("alarmMetadata").document(alarmID).updateData(["enabled": sender.isOn])
        }
        
        // Enable/Disable notifications
        if sender.isOn {
            if self.global_snooze {
                sender.setOn(false, animated: true)
                return
            }
            let date = timestampTime.dateValue()
            alarmScheduler.setNotificationWithTimeAndDate(name: alarmName, time: date, recurring: self.recurring, uuidStr: alarmID)
        } else {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [alarmID])
        }
    }
    
    @IBAction func onAcceptedEmojiPressed(_ sender: Any) {
        acceptedButton.imageView?.alpha = 1.0
        acceptedLabel.alpha = 1.0

        declinedButton.imageView?.alpha = 0.5
        declinedLabel.alpha = 0.5
        
        pendingButton.imageView?.alpha = 0.5
        pendingLabel.alpha = 0.5
        
        curIcon = acceptIcon
        nameList = acceptedList
        status = .accepted
        self.acceptedLabel.text = "Confirmed (\(self.acceptedList.count))"
        self.responseTableView?.reloadData()
    }
    
    @IBAction func onDeclinedEmojiPressed(_ sender: Any) {
        declinedButton.imageView?.alpha = 1.0
        declinedLabel.alpha = 1.0
        
        acceptedButton.imageView?.alpha = 0.5
        acceptedLabel.alpha = 0.5
        
        pendingButton.imageView?.alpha = 0.5
        pendingLabel.alpha = 0.5
        
        curIcon = declinedIcon
        nameList = declinedList
        status = .declined
        self.declinedLabel.text = "Declined (\(self.declinedList.count))"
        self.responseTableView?.reloadData()
    }
    
    @IBAction func onPendingEmojiPressed(_ sender: Any) {
        pendingButton.imageView?.alpha = 1.0
        pendingLabel.alpha = 1.0
        
        declinedButton.imageView?.alpha = 0.5
        declinedLabel.alpha = 0.5
        
        acceptedButton.imageView?.alpha = 0.5
        acceptedLabel.alpha = 0.5
        
//        curIcon = UIImage(named: "NotificationAlert")
        curIcon = nil
        nameList = pendingList
        status = .pending
        self.pendingLabel.text = "Pending (\(self.pendingList.count))"
        self.responseTableView?.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
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
    func extractTimeFromDate(time: Timestamp?) -> String {
        if let time = time?.dateValue() {
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
}

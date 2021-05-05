//
//  NotificationsViewController.swift
//  beepboop
//
//  Created by Evan Peng on 3/25/21.
//

import UIKit
import FirebaseCore
import Firebase
import CoreData

enum Notifications {
    case friendUpdate(String, Bool) // name, accepted or not
    case alarmChange(String, String, String, String, String) // name, old time, old date, new time, new date
    case alarmUpdate(String, String, Bool) // user name, alarm name, accepted or not
    
    var description: String {
        get {
            switch self {
            case .friendUpdate(let name, let status):
                return "\(name);\(status)"
            case .alarmChange(let name, let oldTime, let oldDate, let newTime, let newDate):
                return "\(name);\(oldTime);\(oldDate);\(newTime);\(newDate)"
            case .alarmUpdate(let user, let alarm, let status):
                return "\(user);\(alarm);\(status)"
            }
        }
    }
    
    static func getNotificationType(raw: String) -> Notifications {
        let vals = raw.components(separatedBy: ";")
        if vals.count == 2 { // friend
            if vals[1] == "true" {
                return friendUpdate(vals[0], true)
            }
            return friendUpdate(vals[0], false)
        }
        else if vals.count == 3 { // alarm update
            if vals[2] == "true" {
                return alarmUpdate(vals[0], vals[1], true)
            }
            return alarmUpdate(vals[0], vals[1], false)
        }
        else { // alarm change
            return alarmChange(vals[0], vals[1], vals[2], vals[3], vals[4])
        }
    }
}

extension Notifications: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Notifications.getNotificationType(raw: rawValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var notifTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var alarmRef: CollectionReference!
    var userRef: CollectionReference!
    var friendRequests: [String]!
    var alarmRequests: [String]!
    var notifications: [Notifications]!
    var currentUserName: String!
    
    private let alarmRequestIdentifier = "AlarmRequestTableViewCell"
    private let alarmUpdateIdentifier = "AlarmUpdateTableViewCell"
    private let friendRequestIdentifier = "FriendRequestTableViewCell"
    private let friendUpdateIdentifier = "FriendUpdateTableViewCell"
    private let alarmChangeIdentifier = "AlarmChangeTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notifTableView.delegate = self
        self.notifTableView.dataSource = self
        self.notifTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.notifTableView.separatorColor = .clear
        
        alarmRef = Firestore.firestore().collection("alarmData")
        userRef = Firestore.firestore().collection("userData")
        
        
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.loadNewData()
    }
    
    // MARK: - Table Functions
    
    /*
     Required count of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notifications == nil {
            return 0
        }
        if segCtrl.selectedSegmentIndex == 0 { // Alarms
            print(self.notifications.filter({$0.description.components(separatedBy: ";").count > 2}).count + self.alarmRequests.count)
            return self.notifications.filter({$0.description.components(separatedBy: ";").count > 2}).count + self.alarmRequests.count
        }
        else { // Friends/Groups
            print(self.notifications.filter({$0.description.components(separatedBy: ";").count == 2}).count + self.friendRequests.count)
            return self.notifications.filter({$0.description.components(separatedBy: ";").count == 2}).count + self.friendRequests.count
        }
    }
    
    /*
     Generate the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if segCtrl.selectedSegmentIndex == 0 { // Alarms
            if row < self.alarmRequests.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmRequestIdentifier, for: indexPath as IndexPath) as! AlarmRequestTableViewCell
                print(self.alarmRequests[row])
                populateAlarmRequestCell(requestUID: self.alarmRequests[row], cell: cell, tag: row)
                let babyPink = UIColor(red: 1.00, green: 0.79, blue: 0.81, alpha: 1.00) // hex: #FFC9CE
                cell.contentView.backgroundColor = babyPink
                return cell // Need to put these in all if to maintain type
            }
            else {
                let alarmNotifications = self.notifications.filter({$0.description.components(separatedBy: ";").count > 2})
                let alarmNotification = alarmNotifications[row - self.alarmRequests.count]
                switch alarmNotification {
                case .alarmChange(let name, let oldTime, let oldDate, let newTime, let newDate):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmUpdateIdentifier, for: indexPath as IndexPath) as! AlarmUpdateTableViewCell
                    populateAlarmUpdateCell(name: name, oldTime: oldTime, oldDate: oldDate, newTime: newTime, newDate: newDate, cell: cell)
                    let pastelGreen = UIColor(red: 0.58, green: 0.92, blue: 0.78, alpha: 1.00) // hex: #95EBC8
                    cell.contentView.backgroundColor = pastelGreen
                    return cell
                case .alarmUpdate(let name, let alarm, let status):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmChangeIdentifier, for: indexPath as IndexPath) as! AlarmRequestUpdateTableViewCell
                    populateAlarmRequestUpdateCell(name: name, alarmName: alarm, status: status, cell: cell)
                    let doveEggBlue = UIColor(red: 0.76, green: 0.87, blue: 1.00, alpha: 1.00) // hex: #C1DDFF
                    cell.contentView.backgroundColor = doveEggBlue
                    return cell
                default: // should not be possible
                    print("ERROR Should not be possible")
                }
            }
        }
        else { // Friends/Groups
            if row < self.friendRequests.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: self.friendRequestIdentifier, for: indexPath as IndexPath) as! FriendRequestTableViewCell
                populateFriendRequestCell(requestUID: self.friendRequests[row], cell: cell, tag: row)
                let orangeGold = UIColor(red: 1.00, green: 0.83, blue: 0.52, alpha: 1.00) // hex: #FFD385
                cell.contentView.backgroundColor = orangeGold
                return cell
            }
            else {
                let friendNotifications = self.notifications.filter({$0.description.components(separatedBy: ";").count == 2})
                let friendNotification = friendNotifications[row - self.friendRequests.count]
                switch friendNotification {
                case .friendUpdate(let name, let status):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.friendUpdateIdentifier, for: indexPath as IndexPath) as! FriendUpdateTableViewCell
                    populateFriendUpdateCell(uid: name, status: status, cell: cell)
                    let lightGreen = UIColor(red: 0.69, green: 1.00, blue: 0.74, alpha: 1.00) // hex: #AFFFBC
                    cell.contentView.backgroundColor = lightGreen
                    return cell
                default:
                    print("ERROR in Friends should not be possible")
                }
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmChangeIdentifier)
        return cell!
    }
    
    /*
     Remove notification from table view by swiping to delete
     Don't allow swiping of requests
     TODO: Need to figure out calculations
     */
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cellId = tableView.cellForRow(at: indexPath)?.reuseIdentifier
        if editingStyle == .delete && cellId != self.alarmRequestIdentifier && cellId != self.friendRequestIdentifier {
            // Delete notifications
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    */
    
    // MARK: - Cell Populating Methods
    
    func populateAlarmRequestCell(requestUID: String, cell: AlarmRequestTableViewCell, tag: Int) {
        alarmRef.document(requestUID).getDocument { (alarmDoc, error) in
            guard let alarmDoc = alarmDoc, alarmDoc.exists else {
                print("Could not find alarm \(String(describing: error))")
                return
            }
            self.userRef.document((alarmDoc.get("userList") as! [String])[0]).getDocument { (userDoc, error) in
                guard let userDoc = userDoc, userDoc.exists else {
                    print("Could not find owner of \(requestUID): \(error!)")
                    return
                }
                cell.alarmNameLabel.text = alarmDoc.get("name") as? String
                cell.alarmNameLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
                cell.alarmFriendLabel.text = userDoc.get("name") as? String
                cell.alarmFriendLabel.font = UIFont(name: "JosefinSans-Regular", size: 15.0)
                cell.alarmTimeLabel.text = self.extractTimeFromDate(time: alarmDoc.get("time") as? Timestamp)
                cell.alarmTimeLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
                cell.alarmDateLabel.text = self.extractDate(time: alarmDoc.get("time") as? Timestamp)
                cell.alarmDateLabel.font = UIFont(name: "JosefinSans-Regular", size: 15.0)
                cell.alarmAcceptButton.tag = tag
                cell.alarmDenyButton.tag = tag
            }
        }
    }
    
    func populateAlarmUpdateCell(name: String, oldTime: String, oldDate: String, newTime: String, newDate: String, cell: AlarmUpdateTableViewCell) {
        cell.alarmNameLabel.text = name
        cell.alarmNameLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        cell.alarmOldTimeLabel.text = oldTime
        cell.alarmOldTimeLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        cell.alarmOldDateLabel.text = oldDate
        cell.alarmOldDateLabel.font = UIFont(name: "JosefinSans-Regular", size: 15.0)
        cell.alarmNewTimeLabel.text = newTime
        cell.alarmNewTimeLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        cell.alarmNewDateLabel.text = newDate
        cell.alarmNewDateLabel.font = UIFont(name: "JosefinSans-Regular", size: 15.0)
    }
    
    func populateAlarmRequestUpdateCell(name: String, alarmName: String, status: Bool, cell: AlarmRequestUpdateTableViewCell) {
        cell.alarmUpdate.text = "\(name) \(accepted(status: status)) the invitation for \(alarmName)"
        cell.alarmUpdate.font = UIFont(name: "JosefinSans-Regular", size: 18.0)
    }
    
    func populateFriendRequestCell(requestUID: String, cell: FriendRequestTableViewCell, tag: Int) {
        userRef.document(requestUID).getDocument { (userDoc, error) in
            guard let userDoc = userDoc, userDoc.exists else {
                print("Could not find user \(String(describing: error))")
                return
            }
            // Cannot currently access photoURL directly, will need to store in user
            cell.friendLabel.text = userDoc.get("name") as? String
            cell.friendLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
            cell.friendRequestLabel.font = UIFont(name: "JosefinSans-Regular", size: 14.0)
            if userDoc.get("photoURL") != nil {
                self.loadData(url: URL(string: userDoc.get("photoURL") as! String)!) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Could not find image \(String(describing: error))")
                        return
                    }
                    DispatchQueue.main.async {
                        cell.friendImageView?.image = UIImage(data: data)?.circleMasked
                    }
                }
            }
            cell.acceptButton.tag = tag
            cell.denyButton.tag = tag
        }
    }
    
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func populateFriendUpdateCell(uid: String, status: Bool, cell: FriendUpdateTableViewCell) {
        userRef.document(uid).getDocument { [self] (userDoc, error) in
            guard let userDoc = userDoc, userDoc.exists else {
                print("Could not find user \(uid): \(String(describing: error))")
                return
            }
            cell.friendStatus.text = "\(userDoc.get("name") as! String) \(self.accepted(status: status)) your friend request"
            cell.friendStatus.font = UIFont(name: "JosefinSans-Regular", size: 18.0)
            if userDoc.get("photoURL") != nil {
                print("userDoc")
                self.loadData(url: URL(string: userDoc.get("photoURL") as! String)!) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Could not find image \(String(describing: error))")
                        return
                    }
                    DispatchQueue.main.async {
                        cell.friendImageView?.image = UIImage(data: data)?.circleMasked
                    }
                }
            }
        }
    }
    
    // MARK: - Accept/Deny Friends/Alarms
    
    // Needs to send the notification to the user then add the alarm to the current user
    @IBAction func acceptAlarm(_ sender: UIButton) {
        alarmAcceptDeny(index: sender.tag, accepted: true)
    }
    
    @IBAction func denyAlarm(_ sender: UIButton) {
        alarmAcceptDeny(index: sender.tag, accepted: false)
    }
    
    func alarmAcceptDeny(index: Int, accepted: Bool) {
        let requestUID = self.alarmRequests[index]
        alarmRef.document(requestUID).getDocument { (alarmDoc, error) in
            guard let alarmDoc = alarmDoc, alarmDoc.exists else {
                print("Could not find alarm \(String(describing: error))")
                return
            }
            guard let user = Auth.auth().currentUser else {
                print("No current user \(error!)")
                return
            }
            let senderUID = (alarmDoc.get("userList") as! [String])[0]
            let notification = Notifications.alarmUpdate(self.currentUserName, alarmDoc.get("name") as! String, accepted).description
            // Add current user to alarm's uid list
            if accepted {
                self.alarmRef.document(requestUID).updateData(["userList": FieldValue.arrayUnion([user.uid]), "userStatus.\(user.uid)": "Accepted"])
                self.userRef.document(user.uid).collection("alarmMetadata").document(requestUID).setData(["enabled": true, "snooze": false])
            }
            else {
                self.alarmRef.document(requestUID).updateData(["userStatus.\(user.uid)": "Denied"])
            }
            
            // Remove alarm from sender's alarmRequestsSent list and add to notifications
            self.userRef.document(senderUID).updateData([
                "alarmRequestsSent": FieldValue.arrayRemove([requestUID]),
                "notifications": FieldValue.arrayUnion([notification])
            ])
            
            // Remove alarm from current alarmRequestsReceived list
            self.userRef.document(user.uid).updateData(["alarmRequestsReceived": FieldValue.arrayRemove([requestUID])])
            
            // TODO: Find a better way
            self.loadNewData()
            // Need to figure out appropriate way to delete
            // self.notifTableView.deleteRows(at: [index as IndexPath], with: .fade)
        }
    }
    
    @IBAction func acceptFriend(_ sender: UIButton) {
        self.handleFriendRequestResponse(index: sender.tag, accepted: true)
    }
    
    @IBAction func denyFriend(_ sender: UIButton) {
        self.handleFriendRequestResponse(index: sender.tag, accepted: false)
    }
    
    func handleFriendRequestResponse(index: Int, accepted: Bool) {
        let requestUID = self.friendRequests[index]
        if let user = Auth.auth().currentUser {
            // Accept the requester

            if accepted {
                self.userRef.document(user.uid).updateData(["friendsList": FieldValue.arrayUnion([requestUID])])
                self.userRef.document(requestUID).updateData(["friendsList": FieldValue.arrayUnion([user.uid])])
            }

            // Remove from current user's friendRequestReceived list
            self.userRef.document(user.uid).updateData(["friendRequestsReceived": FieldValue.arrayRemove([requestUID])])

            // Remove request from sender's friendRequestsSent list and add to notifications
            let notification = Notifications.friendUpdate(user.uid, accepted).description
            self.userRef.document(requestUID).updateData([
                "friendRequestsSent": FieldValue.arrayRemove([user.uid]),
                "notifications": FieldValue.arrayUnion([notification])
            ])
            // TODO: Find a better way
            self.loadNewData()
            // Need to figure out appropriate way to delete
            // self.notifTableView.deleteRows(at: [index as IndexPath], with: .fade)
        }
        else {
            print("No current user!")
        }
    }
    
    // MARK: - Utility
    
    @IBAction func segmentChanged(_ sender: Any) {
        notifTableView.reloadData()
    }
    
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
    
    func extractDate(time: Timestamp?) -> String {
        if let time = time?.dateValue() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, MMM d"
            return dateFormatter.string(from: time)
        } else {
            return "Error when extracting date from Date object"
        }
    }
    
    func accepted(status: Bool) -> String {
        return status ? "accepted" : "declined"
    }
    
    func loadNewData() {
        if let user = Auth.auth().currentUser {
            userRef.document(user.uid).getDocument { (document, error) in
                guard let document = document, document.exists else {
                    if(error != nil) {
                        print("error not nil: ", error)
                    }
                    return
                }
                print("document: ", document)
                if(!document.exists && error == nil) {
                    print("case where doc does not exists and error is nil")
                }
                
                self.currentUserName = document.get("name") as? String // Don't want to store uid
                self.friendRequests = document.get("friendRequestsReceived") as? [String]
                self.alarmRequests = document.get("alarmRequestsReceived") as? [String]
                let rawNotifications = document.get("notifications") as! [String]
                self.notifications = rawNotifications.map {Notifications.getNotificationType(raw: $0)}
                self.notifTableView.reloadData()
            }
        }
        else {
            print("No Current User Found")
        }
    }
}

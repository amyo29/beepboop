//
//  NotificationsViewController.swift
//  beepboop
//
//  Created by Evan Peng on 3/25/21.
//

import UIKit
import FirebaseCore
import Firebase

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
        self.loadNewData()

        // Do any additional setup after loading the view.
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
                return cell // Need to put these in all if to maintain type
            }
            else {
                let alarmNotifications = self.notifications.filter({$0.description.components(separatedBy: ";").count > 2})
                let alarmNotification = alarmNotifications[row - self.alarmRequests.count]
                switch alarmNotification {
                case .alarmChange(let name, let oldTime, let oldDate, let newTime, let newDate):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmUpdateIdentifier, for: indexPath as IndexPath) as! AlarmUpdateTableViewCell
                    populateAlarmUpdateCell(name: name, oldTime: oldTime, oldDate: oldDate, newTime: newTime, newDate: newDate, cell: cell)
                    return cell
                case .alarmUpdate(let name, let alarm, let status):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmChangeIdentifier, for: indexPath as IndexPath) as! AlarmRequestUpdateTableViewCell
                    populateAlarmRequestUpdateCell(name: name, alarmName: alarm, status: status, cell: cell)
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
                return cell
            }
            else {
                let friendNotifications = self.notifications.filter({$0.description.components(separatedBy: ";").count == 2})
                let friendNotification = friendNotifications[row - self.friendRequests.count]
                switch friendNotification {
                case .friendUpdate(let name, let status):
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.friendUpdateIdentifier, for: indexPath as IndexPath) as! FriendUpdateTableViewCell
                    populateFriendUpdateCell(name: name, status: status, cell: cell)
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
                cell.alarmFriendLabel.text = userDoc.get("name") as? String
                cell.alarmTimeLabel.text = self.extractTimeFromDate(time: alarmDoc.get("time") as? Timestamp)
                cell.alarmDateLabel.text = self.extractDate(time: alarmDoc.get("time") as? Timestamp)
                cell.alarmAcceptButton.tag = tag
                cell.alarmDenyButton.tag = tag
            }
        }
    }
    
    func populateAlarmUpdateCell(name: String, oldTime: String, oldDate: String, newTime: String, newDate: String, cell: AlarmUpdateTableViewCell) {
        cell.alarmNameLabel.text = name
        cell.alarmOldTimeLabel.text = oldTime
        cell.alarmOldDateLabel.text = oldDate
        cell.alarmNewTimeLabel.text = newTime
        cell.alarmNewDateLabel.text = newDate
    }
    
    func populateAlarmRequestUpdateCell(name: String, alarmName: String, status: Bool, cell: AlarmRequestUpdateTableViewCell) {
        cell.alarmUpdate.text = "\(name) \(accepted(status: status)) the invitation for \(alarmName)"
    }
    
    func populateFriendRequestCell(requestUID: String, cell: FriendRequestTableViewCell, tag: Int) {
        userRef.document(requestUID).getDocument { (userDoc, error) in
            guard let userDoc = userDoc, userDoc.exists else {
                print("Could not find user \(String(describing: error))")
                return
            }
            // Cannot currently access photoURL directly, will need to store in user
            cell.friendLabel.text = userDoc.get("name") as? String
            cell.acceptButton.tag = tag
            cell.denyButton.tag = tag
        }
    }
    
    func populateFriendUpdateCell(name: String, status: Bool, cell: FriendUpdateTableViewCell) {
        cell.friendStatus.text = "\(name) \(accepted(status: status)) your friend request"
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
                self.userRef.document(user.uid).collection("alarmMetaData").document(requestUID).setData(["enabled": true, "snooze": false])
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
        friendAcceptyDeny(index: sender.tag, accepted: true)
    }
    
    @IBAction func denyFriend(_ sender: UIButton) {
        friendAcceptyDeny(index: sender.tag, accepted: false)
    }
    
    func friendAcceptyDeny(index: Int, accepted: Bool) {
        let requestUID = self.friendRequests[index]
        if let user = Auth.auth().currentUser {
            // Accept the requester
            print("Did we at least get here")

            if accepted {
                self.userRef.document(user.uid).updateData(["friendsList": FieldValue.arrayUnion([requestUID])])
                self.userRef.document(requestUID).updateData(["friendsList": FieldValue.arrayUnion([user.uid])])
            }
            print("Did  least get here")

            // Remove from current user's friendRequestReceived list
            self.userRef.document(user.uid).updateData(["friendRequestsReceived": FieldValue.arrayRemove([requestUID])])
            print("Did get here")

            // Remove request from sender's friendRequestsSent list and add to notifications
            let notification = Notifications.friendUpdate(self.currentUserName, accepted).description
            self.userRef.document(requestUID).updateData([
                "friendRequestsSent": FieldValue.arrayRemove([user.uid]),
                "notifications": FieldValue.arrayUnion([notification])
            ])
            print("sere")

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
                    print("Could not find user \(error!)")
                    return
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

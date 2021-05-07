//
//  GroupViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/25/21.
//

import UIKit
import FirebaseCore
import Firebase
import CoreData

protocol GroupAdder {
    func addGroup(uuid: UUID, name: String, members: [String], alarms: [String], image: UIImage)
    func addAlarm(time: Date, name: String, recurrence: String, snooze: Bool, invitedUsers: [String], groupID: String)
}

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupAdder {
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var userDocRef: DocumentReference!
    var alarmCollectionRef: CollectionReference!
    var userCollectionRef: CollectionReference!
    var groupCollectionRef: CollectionReference!
    var currentUserUid: String?
    
    private var groupsList: [GroupCustom] = []
    private let groupTableViewCellIdentifier = "GroupTableViewCell"
    private let groupsToCreateGroupsSegueIdentifier = "GroupsToCreateGroups"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        self.groupTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.groupTableView.separatorColor = .clear

        // Do any additional setup after loading the view.
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
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
        self.userCollectionRef = Firestore.firestore().collection("userData")
        self.alarmCollectionRef = Firestore.firestore().collection("alarmData")
        self.groupCollectionRef = Firestore.firestore().collection("groupData")
        self.userDocRef = userCollectionRef.document(currentUserUid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.groupTableView)
      
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
        
        self.updateGroupsFirestore()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.groupTableViewCellIdentifier, for: indexPath as IndexPath) as! GroupTableViewCell
        
        let group = self.groupsList[row]
        
        self.populateCell(group: group, cell: cell)
        self.colourCell(group: group, cell: cell, row: row)
                
        return cell
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// set animation variables
        let duration = 0.5
        let delayFactor = 0.05
        let rowHeight: CGFloat = 62
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            print("Just Swiped Edit", action)
            completion(true)
            self.performSegue(withIdentifier: "GroupsToCreateAlarmIdentifier", sender: indexPath)
        }
        edit.backgroundColor = UIColor(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 0)
//        edit.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image {
//            _ in UIImage(named: "EditIcon")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
//        }
        edit.image = UIImage(named: "AddIcon")

        let responses = UIContextualAction(style: .normal, title: "Responses") { (action, view, completion) in
            print("Just Swiped Responses", action)
//            self.performSegue(withIdentifier: "CalendarToAlarmMetadataSegueIdentifier", sender: indexPath)
            completion(true)
        }
        responses.backgroundColor = UIColor(red: 0.5725490451, green: 0.2313725501, blue: 0, alpha: 0)
        responses.image = UIImage(named: "InfoIcon")
//        responses.image = UIGraphicsImageRenderer(size: CGSize(width: 90, height: 90)).image {
//            _ in UIImage(named: "ResponseIcon")?.draw(in: CGRect(x: 0, y: 0, width: 90, height: 90))
//        }

        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            print("Just Swiped Deleted", action)
//            if let uuid = self.alarmList[indexPath.row].uuid,
//               let currentUserUid = self.currentUserUid {
//                let notificationCenter = UNUserNotificationCenter.current()
//                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
//                // alert asking for complete removal of alarm and not just user id from alarm (if owner of alarm)
//                // add owner uid for each alarm in create alarm
//                self.userDocRef.collection("alarmMetadata").document(uuid).delete()
//                self.alarmCollectionRef.document(uuid).updateData([
//                    "userStatus": FieldValue.arrayRemove([currentUserUid]),
//                    "userList": FieldValue.arrayRemove([currentUserUid])
//                ])
//
////                self.updateAlarmsFirestore()
//                // TODO: remove alarm data from collection if userStatus is empty
//            }
//
//            self.alarmList.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completion(false)
        }
        delete.image = UIImage(named: "ExitIcon")
//        delete.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image {
//            _ in UIImage(named: "DeleteIcon")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
//        }
        delete.backgroundColor =  UIColor(red: 0.2436070212, green: 0.5393256153, blue: 0.1766586084, alpha: 0)

        let config = UISwipeActionsConfiguration(actions: [delete, responses, edit])
        config.performsFirstActionWithFullSwipe = false

        return config
   }
    
    func populateCell(group: GroupCustom, cell: GroupTableViewCell) {
        cell.groupNameLabel?.text = group.name
        cell.groupNameLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        if let uuid = group.uuid {
            groupCollectionRef.document(uuid).getDocument { (groupDoc, error) in
                if let groupDoc = groupDoc, groupDoc.exists {
                    if let photoURL = groupDoc.get("photoURL") {
                        self.loadData(url: URL(string: photoURL as! String)!) { data, response, error in
                            guard let data = data, error == nil else {
                                return
                            }
                            DispatchQueue.main.async {
                                cell.groupImageView?.image = UIImage(data: data)?.circleMasked
                            }
                        }
                    } else {
                        cell.groupImageView?.image = UIImage(named: "ProfilePicDefault")
                    }
                }
            }
        }
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func colourCell(group: GroupCustom, cell: GroupTableViewCell, row: Int) {
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
        
        let cellColours = [tiffanyBlue, doveEggBlue, lavender, lilac, babyPink, rose, orangeGold, softYellow, lightGreen, pastelGreen]
        let frequency = row % cellColours.count
        cell.contentView.backgroundColor = cellColours[frequency]
    }
    
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func updateGroupsFirestore() {
        self.groupsList = [GroupCustom]()
        var groupUuids = [String]()
        
        userDocRef.collection("groupMetadata").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    groupUuids.append(document.documentID)
                }

                for groupUuid in groupUuids {
                    let docRef = self.groupCollectionRef.document(groupUuid)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            if let model = GroupCustom(dictionary: document.data()!) {
                                self.groupsList.append(model)
                                self.groupTableView.reloadData()
                            } else {
                            }
                        } 
                    }
                }
            }
        }
    }
    
//    func populateGroupTableWithDummyValues() {
//        self.groupsList = []
//        self.groupsList.append(GroupCustom(name: "ball is life"))
//        self.groupsList.append(GroupCustom(name: "scotts tots"))
//        self.groupsList.append(GroupCustom(name: "bulko fan club"))
//        self.groupsList.append(GroupCustom(name: "haikyuu watch party"))
//        self.groupTableView?.reloadData()
//    }
    

    @IBAction func groupMetadataButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Edit settings for this friend",
            message: "Select action for this friend",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Remove",
                                    style: .destructive,
                                    handler: { (action) -> Void in
                                        
                                        print( "Remove friend from friends list and table view")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Block",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        
                                        print( "Block this user")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Edit",
                                    style: .default,
                                    handler: { (action) -> Void in
                                       
                                        print( "Edit friend")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: { (action) -> Void in
                                    }))
        
       
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addGroup(uuid: UUID, name: String, members: [String], alarms: [String], image: UIImage) {
        // Make call to firestore, add group to group collection
        // Add field under each member for group ownership, send notification
        let groupCollectionRef = Firestore.firestore().collection("groupData")
        let userCollectionRef = Firestore.firestore().collection("userData")
        let newGroup = GroupCustom(name: name, members: members, alarms: alarms, uuid: uuid.uuidString)
        groupCollectionRef.document(uuid.uuidString).setData(newGroup.dictionary)
        
        for member in members {
            userCollectionRef.document(member).collection("groupMetadata").document(uuid.uuidString).setData(["id": uuid.uuidString])
            
            // TODO: add notifications for members once group is created
        }
        
        if let optimizedImageData = image.jpegData(compressionQuality: 0.6) {
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("groups").child(uuid.uuidString).child("\(uuid.uuidString)-profilePic.jpg")
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "image/jpeg"
            
            imageRef.putData(optimizedImageData, metadata: uploadMetaData) { (optimizedImageData, error) in
                guard let _ = optimizedImageData else {
                    print("An error occurred while uploading profile pic")
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("An error occurred while downloading profile pic")
                      return
                    }
                    
                    groupCollectionRef.document(uuid.uuidString).updateData(["photoURL": downloadURL.absoluteString])
                }
            }
        }
    }
    
    // MARK: - Delegate functions
    
    func addAlarm(time: Date, name: String, recurrence: String, snooze: Bool, invitedUsers: [String], groupID: String) {
        self.addAlarmToFirestore(time: time, name: name, recurrence: recurrence, snooze: snooze, invitedUsers: invitedUsers, groupID: groupID)
    }
    
    // MARK: - Firestore functions
    
    func addAlarmToFirestore(time: Date, name: String, recurrence: String, snooze: Bool, invitedUsers: [String], groupID: String) {
        let userStatus = self.getStatusForUsers(invitedUsers: invitedUsers)
        let uuid = UUID()
        let newAlarm = AlarmCustom(name: name, time: time, recurrence: recurrence, uuid: uuid.uuidString, userList: invitedUsers, userStatus: userStatus)
        alarmCollectionRef.document(uuid.uuidString).setData(newAlarm.dictionary)
        
        for userUid in invitedUsers {
            let tempUserDocRef = userCollectionRef.document(userUid)
            tempUserDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    tempUserDocRef.collection("alarmMetadata").document(uuid.uuidString).setData(["snooze": snooze, "enabled": !snooze])
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        // Add alarm to Group Collection in Firestore
        let groupDocRef = groupCollectionRef.document(groupID)
        groupDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let existingAlarms = document.get("alarms") as? [String] else {
                    print("unable to get existing alarms from groupDoc in GroupViewController when creating a new alarm")
                    return
                }
                groupDocRef.updateData(["alarms": [uuid.uuidString] + existingAlarms])
            }
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.groupsToCreateGroupsSegueIdentifier,
           let destination = segue.destination as? CreateGroupViewController {
            destination.delegate = self
        } else if segue.identifier == "GroupsToCreateAlarmIdentifier", let destination = segue.destination as? CreateAlarmViewController, let indexPath = sender as? IndexPath {
            destination.delegate = self
            destination.groupAlarm = true
            destination.groupList = self.groupsList[indexPath.row].members!
            destination.groupID = self.groupsList[indexPath.row].uuid!
            print("destination.groupList value", destination.groupList)
        }
    }
}

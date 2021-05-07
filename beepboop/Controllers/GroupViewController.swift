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
}

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupAdder {
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var userDocRef: DocumentReference!
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.groupsToCreateGroupsSegueIdentifier,
           let destination = segue.destination as? CreateGroupViewController {
            destination.delegate = self
        }
    }
    

}

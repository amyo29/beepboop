//

//  ShareToFriendsViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/12/21.
//

import UIKit
import FirebaseCore
import Firebase

class ShareToFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var shareToFriendsTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    var dataListener: ListenerRegistration!
    private var documents: [DocumentSnapshot] = []
    var userDocRef: DocumentReference!
    
    private var friendUuidList: [String]!
    private var friendsList: [UserCustom] = []
    private var sharedToList: [String] = []
    var userCollectionRef: CollectionReference!
    private var currentUserUid: String!
    private let shareToFriendsTableViewCellIdentifier = "ShareToFriendsTableViewCell"
    
    var delegate: UIViewController!
    var previousDelegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.shareToFriendsTableView.delegate = self
        self.shareToFriendsTableView.dataSource = self
        self.shareToFriendsTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.shareToFriendsTableView.separatorColor = .clear
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
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
        
//        userCollectionRef.whereField("userId", isEqualTo: self.currentUserUid!).getDocuments(
//            completion:
//            { (snapshot, error) in
//                if let error = error {
//                    print("An error occurred when retrieving the user: \(error.localizedDescription)")
//                } else if snapshot!.documents.count != 1 {
//                    print("The specified user with UUID \(self.currentUserUid!) does not exist.")
//                } else {
//                    self.userDocRef = snapshot?.documents.first?.reference
//                    #imageLiteral(resourceName: "AddButton-3x.png")           }
//            }
//        )
        
        self.userDocRef = userCollectionRef.document(currentUserUid)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sharedToList = []
        self.friendsList = [UserCustom]()
        self.updateFriendsFirestore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let viewController = self.delegate as? ShareToListUpdater {
            viewController.updateSharedToList(sharedToList: self.sharedToList)
        }
        super.viewWillDisappear(animated)
    }
    
    func mapFriendsToUserStruct(friendUuids: [String]) {
        for friendUuid in friendUuids {
            let docRef = self.userCollectionRef.document(friendUuid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists,
                   let data = document.data() {
                    if let model = UserCustom(dictionary: data) {
                        self.friendsList.append(model)
                        self.shareToFriendsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func updateFriendsFirestore() {
        // Extract friends list from current user's document
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let documentData = document.data()
//                let friendUuids = documentData?["friendsList"] as? [String] ?? [""]
                self.friendUuidList = document.get("friendsList") as? [String] ?? [""]
                self.mapFriendsToUserStruct(friendUuids: self.friendUuidList)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Increases efficiency of app by only listening to data when view is on screen
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        dataListener.remove()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("In tableView count method, count: ", self.friendsList.count)
        return self.friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In tableView cell render method, count: ", self.friendsList.count)
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.shareToFriendsTableViewCellIdentifier, for: indexPath as IndexPath) as! ShareToFriendsTableViewCell
        let friend = row
        cell.shareButton.tag = row
        populateCell(friend: friend, cell: cell)
        return cell
    }
    
    func populateCell(friend: Int, cell: ShareToFriendsTableViewCell) {
        print("in populateCell, friend=\(friend)")
        
        cell.friendNameLabel?.text = self.friendsList[friend].name
        cell.friendNameLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        userCollectionRef.document(self.friendUuidList[friend]).getDocument { (friendDoc, error) in
            if let friendDoc = friendDoc, friendDoc.exists {
                let photoURL = friendDoc.get("photoURL")
                if photoURL == nil {
                    cell.friendImageView?.image = UIImage(named: "EventPic") // Default
                    return
                }
                self.loadData(url: URL(string: photoURL as! String)!) { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        cell.friendImageView?.image = UIImage(data: data)?.circleMasked
                    }
                }
            }
            else {
                cell.friendImageView?.image = UIImage(named: "EventPic") // Default
            }
        }
    }
    
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Sent",
            message: "You shared this alarm",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Ok",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        
                                        print( "share to friend")
                                    }))
       
        self.present(alertController, animated: true, completion: nil)
        self.addToSharedList(index: sender.tag)
    }
    
    func addToSharedList(index: Int) {
        let friendUID = self.friendUuidList[index]
        self.sharedToList.append(friendUID)
    }

    func shareToFriend(index: Int) {
        let friendUID = self.friendUuidList[index]
        // Add friend's UID to current user's alarmRequestsSent list
        userDocRef.updateData([
            "alarmRequestsSent": FieldValue.arrayUnion([friendUID]),
        ])
        
        // Add current user's UID to friend's alarmRequestsReceived list
        let friendDocRef = userCollectionRef.document(friendUID)
        friendDocRef.updateData([
            "alarmRequestsReceived": FieldValue.arrayUnion([currentUserUid]),
        ])
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

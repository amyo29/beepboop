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
    var dataListener: ListenerRegistration!
    private var documents: [DocumentSnapshot] = []
    var userDocRef: DocumentReference!
    
    private var shareToFriendsList: [UserCustom] = [] // string?
    private var friendsList: [UserCustom] = []
    var userCollectionRef: CollectionReference!
    private var currentUserUid: String!
    private let shareToFriendsTableViewCellIdentifier = "ShareToFriendsTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.shareToFriendsTableView.delegate = self
        self.shareToFriendsTableView.dataSource = self
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
        print("before updatefriendsfirestore")
        updateFriendsFirestore()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.shareToFriendsTableView)
    }
    
    func updateFriendsFirestore() {
        
        // Extract friends list from current user's document
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let documentData = document.data()
                print("Document data: \(documentData)")
                let friendsList = documentData?["friendsList"] as? [String] ?? [""]
                print(friendsList)
            } else {
                print("Document does not exist")
            }
        }
        
        
//        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists
//            
//        }
//
//        let group_array = document["friendsList"] as? Array ?? [""]
//        print(group_array)
//
        
        // For each friend in friends list, get friend's User doc
        // Populate table with friend's User doc data for each friend
        
        
        dataListener = userCollectionRef.whereField("userId", arrayContains: self.currentUserUid!).addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> UserCustom in
                if let model = UserCustom(dictionary: document.data()) {
                    return model
                } else {
                    print(document.data())
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(UserCustom.self) with dictionary \(document.data())")
                }
            }
            self.friendsList = models
            self.documents = snapshot.documents
            
            self.shareToFriendsTableView?.reloadData()
        }
    }
    
    // Increases efficiency of app by only listening to data when view is on screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataListener.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("In tableView count method, count: ", self.friendsList.count)
        return self.friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In tableView cell render method, count: ", self.friendsList.count)
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.shareToFriendsTableViewCellIdentifier, for: indexPath as IndexPath) as! ShareToFriendsTableViewCell
        
        let friend = friendsList[row]
    
        populateCell(friend: friend, cell: cell)
        
        return cell
    }
    
    func populateCell(friend: UserCustom, cell: ShareToFriendsTableViewCell) {
        print("in populateCell, friend=\(friend)")
        cell.friendNameLabel?.text = friend.userId
        cell.friendImageView?.image = UIImage(named: "EventPic") // change to friend user profile pic
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(
            title: "Share to friend",
            message: "Shared to this friend",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Shared",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        
                                        print( "share to friend")
                                    }))
       
        self.present(alertController, animated: true, completion: nil)
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

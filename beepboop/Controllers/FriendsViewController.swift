//
//  FriendsViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

import UIKit
import FirebaseCore
import Firebase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var friendsList: [UserCustom] = []
    private let friendsTableViewCellIdentifier = "FriendsTableViewCell"
    
    var userCollectionRef: CollectionReference!
    var userDocRef: DocumentReference!
    var currentUserUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.friendsTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.friendsTableView.separatorColor = .clear
                
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
        self.userDocRef = userCollectionRef.document(currentUserUid)
        
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        backButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 23.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.friendsTableView)
        self.updateFriendsFirestore()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("In tableView count method, count: ", self.friendsList.count)
        return self.friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In tableView cell render method, count: ", self.friendsList.count)
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.friendsTableViewCellIdentifier, for: indexPath as IndexPath) as! FriendsTableViewCell
        
        let friend = friendsList[row]
    
        populateCell(friend: friend, cell: cell)
        
        return cell
    }
    
    func populateCell(friend: UserCustom, cell: FriendsTableViewCell) {
        print("in populateCell, friend=\(friend)")
        cell.friendNameLabel?.text = friend.name
        cell.friendNameLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        cell.friendImageView?.image = UIImage(named: "EventPic") // change to friend user profile pic
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    @IBAction func friendMetadataButtonPressed(_ sender: Any) {
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateFriendsFirestore() {
        self.friendsList = [UserCustom]()
        
        guard let currentUserUid = self.currentUserUid else {
            print("Cannot get current user uid")
            return
        }
        
        self.userCollectionRef.document(currentUserUid).getDocument { (document, error) in
            self.friendsTableView.isHidden = true
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let document = document, document.exists else {
                    print("Error getting documents")
                    return
                }
                
                if let friendUuids = document.get("friendsList") as? [String] {
                    for friendUuid in friendUuids {
                        self.userCollectionRef.document(friendUuid).getDocument { (document, error) in
                            if let document = document,
                               document.exists,
                               let data = document.data() {
                                if let model = UserCustom(dictionary: data) {
                                    self.friendsList.append(model)
                                    self.friendsTableView.reloadData()
                                }
                            }
                               
                        }
                    }
                    self.friendsTableView.isHidden = false

                }
            }
            
        }
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

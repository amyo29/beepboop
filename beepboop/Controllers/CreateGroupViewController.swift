//
//  CreateGroupViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 5/3/21.
//

import UIKit
import FirebaseCore
import Firebase

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var imageButton: UIButton!
    
    private let imagePicker = UIImagePickerController()
    
    private var userDocRef: DocumentReference!
    private var friendUuidList: [String]!
    private var friendsList: [UserCustom] = []
    private var sharedToList: [String] = []
    var userCollectionRef: CollectionReference!
    private var currentUserUid: String!
        
    var delegate: UIViewController!
    private let shareToFriendsTableViewCellIdentifier = "ShareToFriendsTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imagePicker.delegate = self
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.friendsTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.friendsTableView.separatorColor = .clear
        self.groupNameTextField.font = UIFont(name: "JosefinSans-Regular", size: 40.0)

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
        self.userDocRef = userCollectionRef.document(currentUserUid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sharedToList = []
        self.friendsList = [UserCustom]()
        self.updateFriendsFirestore()
    }
    
    func mapFriendsToUserStruct(friendUuids: [String]) {
        for friendUuid in friendUuids {
            let docRef = self.userCollectionRef.document(friendUuid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists,
                   let data = document.data() {
                    if let model = UserCustom(dictionary: data) {
                        self.friendsList.append(model)
                        self.friendsTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In tableView cell render method, count: ", self.friendsList.count)
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.shareToFriendsTableViewCellIdentifier, for: indexPath as IndexPath) as! ShareToFriendsTableViewCell
        self.friendsList.sort {$0.name! < $1.name! }
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
    
    @IBAction func createGroupButtonPressed(_ sender: Any) {
        guard let name = self.groupNameTextField.text,
              name.count > 0 else {
            let alertController = UIAlertController(
                title: "Oops",
                message: "Looks like you forgot to give the group a name. Try again.",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if self.sharedToList.count == 0 {
            let alertController = UIAlertController(
                title: "Oops",
                message: "Looks like this group is empty. Add a friend!",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard let owner = Auth.auth().currentUser?.uid else {
            let alertController = UIAlertController(
                title: "Unknown error",
                message: "We're not sure what happened. Try again?",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        self.sharedToList.append(owner)
        
        if let _ = self.delegate as? GroupViewController,
           let groupViewController = self.delegate as? GroupAdder {
            let uuid = UUID()
            
            groupViewController.addGroup(uuid: uuid, name: name, members: self.sharedToList, alarms: [], image: self.imageButton.backgroundImage(for: .normal)!)
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func changeImageButtonPressed(_ sender: Any) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageButton.setBackgroundImage(pickedImage.circleMasked, for: .normal)
        }

        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

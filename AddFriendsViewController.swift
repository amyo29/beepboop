//
//  AddFriendsViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

/**
 TODO:
 1. Get user email from Firebase-generated user Id and vice versa
 2. Update current logged in user's document's "friendRequestsSent" field with specified friend's uid from email entered
 3. Update friend's user document's "friendRequestsReceived" array field with current user's document uid
 */

import UIKit
import FirebaseCore
import Firebase

class AddFriendsViewController: UIViewController {

    @IBOutlet weak var EnterFriendEmailTextLabel: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    var userCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        guard let email = self.emailTextField.text,
              email.count > 0
        else {
            let alertController = UIAlertController(
                title: "Missing input",
                message: "Please enter your friend's email address",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // get user email from Firebase uid
        Firestore.firestore().collection("userData").whereField("userId", isEqualTo: email).getDocuments(
            completion:
            { (snapshot, error) in
                if let error = error {
                    print("An error occurred when retrieving the user: \(error.localizedDescription)")
                } else if snapshot!.documents.count != 1 {
                    let alertController = UIAlertController(
                        title: "Invalid email",
                        message: "The specified user with email \(email) does not exist.",
                        preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(
                                                title: "Ok",
                                                style: .default,
                                                handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let document = snapshot?.documents.first
                    document?.reference.updateData([
                        "friendRequestsReceived": FieldValue.arrayUnion([email])
                    ])
                }
            }
        )
                
    }
    
    // MARK: - Hide Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

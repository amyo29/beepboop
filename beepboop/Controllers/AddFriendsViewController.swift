//
//  AddFriendsViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

/**
 TODO:
 1. Add check to see whether friend request has already been sent to the other user
 2. Add user name field to UserCustom struct and SignUp Screen, and display name on friends list in FriendsViewController table view
 3. Handle friend request invitation - accept/decline
 */

import UIKit
import FirebaseCore
import Firebase
import CoreData


class AddFriendsViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var instructionTextLabel: UILabel!
    
    var userCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 23.0)
        instructionTextLabel.font = UIFont(name: "JosefinSans-Regular", size: 23.0)
        emailTextField.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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

        //  Update friend's user document's "friendRequestsReceived" array field with current user document's uid
        Firestore.firestore().collection("userData").whereField("userEmail", isEqualTo: email).getDocuments(
            completion:
            { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    let alertController = UIAlertController(
                        title: "Unknown Error",
                        message: "Please try again later.",
                        preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(
                                                title: "Ok",
                                                style: .default,
                                                handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                } else if snapshot!.documents.count != 1 {
                    let alertController = UIAlertController(
                        title: "Someone's missing out",
                        message: "Looks like \(email) hasn't joined beepboop yet. Want to invite them to the club?",
                        preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(
                                                title: "Invite and cure their FOMO",
                                                style: .default,
                                                handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                } else {
                    guard let friendDocument = snapshot?.documents.first else {
                        
                        print("Unreachable State. This document has to exist.")
                        let alertController = UIAlertController(
                            title: "Unknown Error",
                            message: "Please try again later.",
                            preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(
                                                    title: "Ok",
                                                    style: .default,
                                                    handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    print("friendDocument.id: ", friendDocument.documentID)
                    
                    friendDocument.reference.updateData([
                        "friendRequestsReceived": FieldValue.arrayUnion([currentUserUid])
                    ])
                    
                    //Update current logged in user's document's "friendRequestsSent" field with specified friend's uid from email entered
                    Firestore.firestore().collection("userData").document(currentUserUid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let friendUserId = friendDocument.documentID
                            document.reference.updateData([
                                "friendRequestsSent": FieldValue.arrayUnion([friendUserId])
                            ])
                            
                            let alertController = UIAlertController(
                                title: "Friend Request Sent",
                                message: "Friend request sent to \(email).",
                                preferredStyle: .alert)
                            
                            alertController.addAction(UIAlertAction(
                                                        title: "Ok",
                                                        style: .default,
                                                        handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            return
                        } else {
                            print("Document does not exist")
                        }
                    }
                    
//                    Firestore.firestore().collection("userData").whereField("userId", isEqualTo: currentUserUid).getDocuments(completion:
//                        { (snapshot, error) in
//                            if let error = error {
//                                print("An error occurred when retrieving the user: \(error.localizedDescription)")
//                            } else if snapshot!.documents.count != 1 {
//                                print("Multiple users share this email. Please contact our tech support.")
//                            } else {
//                                guard let document = snapshot?.documents.first,
//                                      let friendUserId = friendDocument.get("userId") else {
//                                    print("what is going on")
//                                    return
//                                }
//
//                                document.reference.updateData([
//                                    "friendRequestsSent": FieldValue.arrayUnion([friendUserId])
//                                ])
//
//                                let alertController = UIAlertController(
//                                    title: "Friend Request Sent",
//                                    message: "Friend request sent to \(email).",
//                                    preferredStyle: .alert)
//
//                                alertController.addAction(UIAlertAction(
//                                                            title: "Ok",
//                                                            style: .default,
//                                                            handler: nil))
//
//                                self.present(alertController, animated: true, completion: nil)
//                                return
//                            }
//                        }
//                    )
                }
            }
        )
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Hide Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

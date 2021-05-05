//
//  LoginViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/23/21.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import CoreData


class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private let signUpToMainSegueIdentifier = "SignUpToMain"
    
    private var userCollectionRef: CollectionReference!
    
    private var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userCollectionRef = Firestore.firestore().collection("userData")


        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() {
            auth, user in

            if let user = user {
                self.userID = user.uid
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
                self.performSegue(withIdentifier: self.signUpToMainSegueIdentifier, sender: nil)
            }
        }
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
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let email = self.emailTextField.text,
              let name = self.nameTextField.text,
              let password = self.passwordTextField.text,
              let confirmPassword = self.confirmPasswordTextField.text,
              email.count > 0,
              name.count > 0,
              password.count > 0,
              confirmPassword.count > 0
        else {
            let alertController = UIAlertController(
                title: "Missing input",
                message: "Please enter your email, name, and password, and confirm your password above.",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if password != confirmPassword {
            let alertController = UIAlertController(
                title: "Passwords do not match",
                message: "Please check your password again",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) {
            user, error in
            if error == nil, let user = user {
                // Create user document in Firestore
                self.userID = user.user.uid
//                let newUser = UserCustom( userEmail: email, name: name, alarmData: nil, snoozeEnabled: false, darkModeEnabled: false, friendRequestsReceived: nil, friendRequestsSent: nil, alarmRequestsReceived: nil, alarmRequestsSent: nil, notifications: nil)
                
                let newUser = UserCustom( userEmail: email, name: name, snoozeEnabled: false, darkModeEnabled: false, friendRequestsReceived: nil, friendRequestsSent: nil, alarmRequestsReceived: nil, alarmRequestsSent: nil, notifications: nil)
//                self.userCollectionRef.addDocument(data: newUser.dictionary)
                self.userCollectionRef.document(user.user.uid).setData(newUser.dictionary)
                Auth.auth().signIn(withEmail: email, password: password)
            } else {
                if let error = error, user == nil {
                    let alertController = UIAlertController(
                        title: "Unknown error",
                        message: error.localizedDescription,
                        preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(
                                                title: "Ok",
                                                style: .default,
                                                handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == self.signUpToMainSegueIdentifier,
//           let tabBarController = segue.destination as? UITabBarController,
//           let destination = tabBarController.viewControllers?.first as? HomeViewController {
//            destination.userID = self.userID
//        }
//    }
//
    
    // MARK: - Hide Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

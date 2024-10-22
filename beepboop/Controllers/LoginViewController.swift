//
//  LoginViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/23/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
    
import CoreData

class LoginViewController: UIViewController, LoginButtonDelegate  {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var userId: String!
    
    private let loginToMainSegueIdentifier = "LoginToMain"
    let facebookLoginButton = FBLoginButton(frame: .zero, permissions: [.publicProfile])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.isHidden = true
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
//        clearCoreData()
//        do {
//            try Auth.auth().signOut()
//
//        } catch {
//            print("Error occurred signing out of this account.")
//        }

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() {
            auth, user in

            if let user = user {
                self.userId = user.uid
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
                self.performSegue(withIdentifier: self.loginToMainSegueIdentifier, sender: nil)
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
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        // TODO: Add password validation
        guard let email = self.emailTextField.text,
              let password = self.passwordTextField.text,
              email.count > 0,
              password.count > 0
        else {
            let alertController = UIAlertController(
                title: "Missing input",
                message: "Please enter your email and password",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(
                                        title: "Ok",
                                        style: .default,
                                        handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
                
        Auth.auth().signIn(withEmail: email, password: password) {
            user, error in
            if let error = error, user == nil {
                let alertController = UIAlertController(
                    title: "Invalid sign-in",
                    message: error.localizedDescription,
                    preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(
                                            title: "Ok",
                                            style: .default,
                                            handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func googleLoginButtonPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == self.loginToMainSegueIdentifier,
//           let tabBarController = segue.destination as? UITabBarController,
//           let destination = tabBarController as? MainViewController {
//            destination.userEmail = self.userEmail
//        }
//    }

    @IBAction func facebookLoginButtonPressed(_ sender: Any) {
        facebookLoginButton.sendActions(for: .touchUpInside)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
           print(error.localizedDescription)
           return
         }
        if AccessToken.current == nil {
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            print("authentication error \(error.localizedDescription)")
            return
          }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        return
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == self.loginToMainSegueIdentifier,
//           let tabBarController = segue.destination as? UITabBarController,
//           let destination = tabBarController.viewControllers?.first as? HomeViewController {
//            destination.userID = self.userId
//        }
//    }
    
    // MARK: - Hide Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func clearCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alarm")
        
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                    print("\(result.value(forKey:"name")!) has been deleted")
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }

}

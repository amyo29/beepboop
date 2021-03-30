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

class LoginViewController: UIViewController, LoginButtonDelegate  {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let loginToMainSegueIdentifier = "LoginToMain"
    let facebookLoginButton = FBLoginButton(frame: .zero, permissions: [.publicProfile])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.isHidden = true
        
        GIDSignIn.sharedInstance()?.presentingViewController = self

//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print("oopsie")
//        }

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() {
            auth, user in

            if let _ = user {
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
                self.performSegue(withIdentifier: self.loginToMainSegueIdentifier, sender: nil)
            }
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
    
//      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == self.loginToMainSegueIdentifier,
//           let tabBarController = segue.destination as? UITabBarController,
//           let destination = tabBarController as? MainViewController {
//            destination.userEmail = self.userEmail
//        }
//    }
    
    // MARK: - Hide Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

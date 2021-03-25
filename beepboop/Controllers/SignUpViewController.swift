//
//  LoginViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/23/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private let signUpToMainSegueIdentifier = "SignUpToMain"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() {
            auth, user in

            if let _ = user {
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
                self.performSegue(withIdentifier: self.signUpToMainSegueIdentifier, sender: nil)
            }
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let email = self.emailTextField.text,
              let password = self.passwordTextField.text,
              let confirmPassword = self.confirmPasswordTextField.text,
              email.count > 0,
              password.count > 0,
              confirmPassword.count > 0
        else {
            let alertController = UIAlertController(
                title: "Missing input",
                message: "Please enter your email and password, and confirm your password above.",
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
            if error == nil {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Hide Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

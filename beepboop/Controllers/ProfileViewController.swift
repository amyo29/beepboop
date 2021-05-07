//
//  ProfileViewController.swift
//  beepboop
//
//  Created by Evan Peng on 3/25/21.
//

import UIKit
import Firebase
import FirebaseStorage
import CoreData

extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect  { .init(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        guard let cgImage = cgImage?
            .cropping(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                              y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = false   
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: format.scale, orientation: imageOrientation)
            .draw(in: .init(origin: .zero, size: breadthSize))
        }
    }
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var snoozeSwitch: UISwitch!
    @IBOutlet weak var darkmodeSwitch: UISwitch!
        
    @IBOutlet weak var snoozeLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var blockedButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        let user = Auth.auth().currentUser
        if let user = user {
            loadProfilePic(user: user)
            loadUserName(user: user)
            loadUserEmail(user: user)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            var fetchedResults: [NSManagedObject]
            
            do {
                let count = try context.count(for: fetchRequest)
                if count > 0 {
                    try fetchedResults = (context.fetch(fetchRequest) as! [NSManagedObject])
                    snoozeSwitch.setOn((fetchedResults[0].value(forKey: "snoozeEnabled") as? Bool)!, animated: false)
                    darkmodeSwitch.setOn((fetchedResults[0].value(forKey: "darkmodeEnabled") as? Bool)!, animated: false)
                }
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        
        // Do any additional setup after loading the view.
        snoozeLabel.font = UIFont(name: "JosefinSans-Regular", size: 24.0)
        let forestGreen = UIColor(red: 0.26, green: 0.39, blue: 0.34, alpha: 1.00)
        let aqua = UIColor(red: 0.24, green: 0.79, blue: 0.67, alpha: 1.00)
        let peach = UIColor(red: 0.99, green: 0.62, blue: 0.58, alpha: 1.00)
        let orange = UIColor(red: 0.96, green: 0.58, blue: 0.12, alpha: 1.00)
        snoozeLabel.textColor = orange
        darkModeLabel.textColor = aqua
        snoozeSwitch.onTintColor = orange
        snoozeSwitch.tintColor = orange
        snoozeSwitch.thumbTintColor = UIColor.white
        darkmodeSwitch.onTintColor = aqua
        darkmodeSwitch.tintColor = aqua
        darkmodeSwitch.thumbTintColor = UIColor.white
        darkModeLabel.font = UIFont(name: "JosefinSans-Regular", size: 24.0)
        logoutButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 24.0)
        logoutButton.titleLabel?.textColor = orange
        friendsButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 24.0)
        blockedButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 24.0)
        
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
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()

        } catch {
            print("Error occurred when signing out of this account.")
        }
    }
    
    func loadProfilePic(user: Firebase.User?) {
        let photoURL = user?.photoURL
        if let url = photoURL {
            loadData(url: url) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                print("loadProfilePic url \(url)")
                print(response?.suggestedFilename ?? url.lastPathComponent)
                DispatchQueue.main.async() { [weak self] in
                    self?.profileImage.setBackgroundImage(UIImage(data: data)?.circleMasked, for: .normal)
                }
            }
        }
        else {
            profileImage.setBackgroundImage(UIImage.init(named: "ProfilePicDefault"), for: .normal)
        }
    }
    
    func loadUserEmail(user: Firebase.User?) {
        userEmailLabel.text = user?.displayName ?? user?.email ?? "Nil"
        userEmailLabel.font = UIFont(name: "JosefinSans-Regular", size: 22.0)
        let beepboopBlue = UIColor(red: 0.04, green: 0.83, blue: 0.83, alpha: 1.00)
        let peach = UIColor(red: 0.99, green: 0.62, blue: 0.58, alpha: 1.00)
        userEmailLabel.textColor = peach
    }
    
    func loadUserName(user: Firebase.User?) {
        guard let currentUserUid = user?.uid else {
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
        // get current user document from Firestore
        let userCollectionRef = Firestore.firestore().collection("userData")
        let userDocRef = userCollectionRef.document(currentUserUid)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let username = document.get("name") as? String else {
                    self.userNameLabel.isHidden = true
                    return
                }
                self.userNameLabel.text = username
                self.userNameLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    /*
     Asynchronously load url so other functions aren't backlogged
     */
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @IBAction func updateSettings(_sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                try fetchedResults = context.fetch(fetchRequest) as! [NSManagedObject]
                fetchedResults[0].setValue(snoozeSwitch.isOn, forKey: "snoozeEnabled")
                fetchedResults[0].setValue(darkmodeSwitch.isOn, forKey: "darkmodeEnabled")
            }
            else {
                let insert = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: context)
                insert.setValue(snoozeSwitch.isOn, forKey: "snoozeEnabled")
                insert.setValue(darkmodeSwitch.isOn, forKey: "darkmodeEnabled")
            }
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if darkmodeSwitch.isOn {
            self.overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(rgb: 0x262221)
        } else {
            self.overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(rgb: 0xFEFDEC)
        }

        if snoozeSwitch.isOn {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllPendingNotificationRequests()
        }
        else {
            let alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
            if let user = Auth.auth().currentUser {
                let userDoc = Firestore.firestore().collection("userData").document(user.uid)
                let alarms = Firestore.firestore().collection("alarmData")
                userDoc.collection("alarmMetadata").getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents from metadata \(err)")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            if document.get("enabled") as! Bool {
                                alarms.document(document.documentID).getDocument { (alarm, error) in
                                    if let error = error {
                                        print("Could not retreive alarm \(document.documentID) \(error)")
                                    }
                                    else {
                                        if let alarm = alarm, alarm.exists {
                                            if let name = alarm.get("name") as? String,
                                               let recurring = alarm.get("recurrence") as? String,
                                               let sound = alarm.get("sound") as? String,
                                               let time = alarm.get("time") as? Timestamp {
                                                alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time.dateValue(), recurring: recurring, sound: sound, uuidStr: document.documentID)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     START UIImagePickerControllerDelegate Functions
     */
    
    @IBAction func changeProfileImageButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let profilePic = info[.editedImage] as? UIImage, let optimizedImageData = profilePic.jpegData(compressionQuality: 0.6) {
            let activityIndicator = UIActivityIndicatorView.init(style: .medium)
            activityIndicator.startAnimating()
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            
            let storageRef = Storage.storage().reference()
            let user = Auth.auth().currentUser
            let imageRef = storageRef.child("users").child(user!.uid).child("\(user!.uid)-profilePic.jpg")
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "image/jpeg"
            
            // Asynchronous
            imageRef.putData(optimizedImageData, metadata: uploadMetaData) { (optimizedImageData, error) in
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                if error == nil {
                    imageRef.downloadURL(completion: { (url, error) in
                        if error == nil {
                            let changeRequest = user?.createProfileChangeRequest()
                            changeRequest?.photoURL = url
                            changeRequest?.commitChanges(completion: { (error) in
                                if error != nil {
                                    print("Error during createProfileChangeRequest \(String(describing: error?.localizedDescription))")
                                }
                            })

                            let userCollectionRef = Firestore.firestore().collection("userData")
                            userCollectionRef.document(user!.uid).updateData(["photoURL": url?.absoluteString ?? ""])
                        }
                        else {
                            print("Error during storageRef.downloadURL \(String(describing: error?.localizedDescription))")
                        }
                    })
                }
                else {
                    print("Error during imageRef.putData \(String(describing: error?.localizedDescription))")
                }
            }
            self.profileImage.setBackgroundImage(profilePic.circleMasked, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /*
     END UIImagePickerControllerDelegate Functions
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

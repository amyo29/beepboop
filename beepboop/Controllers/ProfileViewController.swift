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
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var snoozeSwitch: UISwitch!
    @IBOutlet weak var darkmodeSwitch: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user {
            loadProfilePic(user: user)
            loadUsername(user: user)
        }
        // Do any additional setup after loading the view.
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
            profileImage.setBackgroundImage(UIImage.init(named: "EventPic"), for: .normal)
        }
    }
    
    func loadUsername(user: Firebase.User?) {
        userLabel.text = user?.displayName ?? user?.email ?? "Nil"
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
            try fetchedResults = context.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedResults.count > 0 { // will be one or 0
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

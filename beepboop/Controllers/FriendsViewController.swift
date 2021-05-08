//
//  FriendsViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

import UIKit
import FirebaseCore
import Firebase
import CoreData


class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var friendsList: [String] = []
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
    
        populateCell(uid: friend, cell: cell)
        colourCell(cell: cell, row: row)
        
        return cell
    }
    
    func populateCell(uid: String, cell: FriendsTableViewCell) {
        print("in populateCell, friend=\(uid)")
        userCollectionRef.document(uid).getDocument { (friendDoc, error) in
            if let friendDoc = friendDoc, friendDoc.exists {
                cell.friendNameLabel?.text = friendDoc.get("name") as? String
                cell.friendNameLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
                
                let photoURL = friendDoc.get("photoURL")
                
                if photoURL == nil {
                    cell.friendImageView?.image = UIImage(named: "EventPic") // Default
                } else {
                    self.loadData(url: URL(string: photoURL as! String)!) { data, response, error in
                        guard let data = data, error == nil else {
                            return
                        }
                        DispatchQueue.main.async {
                            cell.friendImageView?.image = UIImage(data: data)?.circleMasked
                        }
                    }
                }
            }
        }
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func loadData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func colourCell(cell: FriendsTableViewCell, row: Int) {
        let pastelGreen = UIColor(red: 0.58, green: 0.92, blue: 0.78, alpha: 1.00) // hex: #95EBC8
        let lightGreen = UIColor(red: 0.69, green: 1.00, blue: 0.74, alpha: 1.00) // hex: #AFFFBC
        let softYellow = UIColor(red: 0.98, green: 1.00, blue: 0.69, alpha: 1.00) // hex: #F9FFAF
        let orangeGold = UIColor(red: 1.00, green: 0.83, blue: 0.52, alpha: 1.00) // hex: #FFD385
        let rose = UIColor(red: 1.00, green: 0.70, blue: 0.70, alpha: 1.00) // hex: #FFB3B3
        let babyPink = UIColor(red: 1.00, green: 0.79, blue: 0.81, alpha: 1.00) // hex: #FFC9CE
        let lilac = UIColor(red: 1.00, green: 0.75, blue: 0.96, alpha: 1.00) // hex: #FEBEF6
        let lavender = UIColor(red: 0.83, green: 0.82, blue: 1.00, alpha: 1.00) // hex: #D3D1FF
        let doveEggBlue = UIColor(red: 0.76, green: 0.87, blue: 1.00, alpha: 1.00) // hex: #C1DDFF
        let tiffanyBlue = UIColor(red: 0.67, green: 0.95, blue: 1.00, alpha: 1.00) // hex: #ABF1FF
        
        let cellColours = [pastelGreen, lightGreen, softYellow, orangeGold, rose, babyPink, lilac, lavender, doveEggBlue, tiffanyBlue]
        let frequency = row % cellColours.count
        cell.contentView.backgroundColor = cellColours[frequency]
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// set animation variables
        let duration = 0.5
        let delayFactor = 0.05
        let rowHeight: CGFloat = 62
        
//        /// fades the cell by setting alpha as zero and moves the cell downwards, then animates the cell's alpha and returns it to it's original position based on indexPaths
//        cell.transform = CGAffineTransform(translationX: 0, y: rowHeight * 1.4)
//        cell.alpha = 0
//        UIView.animate(
//            withDuration: duration,
//            delay: delayFactor * Double(indexPath.row),
//            options: [.curveEaseInOut],
//            animations: {
//                cell.transform = CGAffineTransform(translationX: 0, y: 0)
//                cell.alpha = 1
//        })
        
        /// moves the cell downwards, then animates the cell's by returning them to their original position with spring bounce based on indexPaths
        cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
        UIView.animate(
            withDuration: duration,
            delay: delayFactor * Double(indexPath.row),
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.1,
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            print("Just Swiped Deleted", action)
            let alertController =  UIAlertController(title: "Are you sure?", message: "This will only remove your friend from your friends list. Any shared alarms and groups will not be deleted.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                self.deleteFriendFirestore(row: indexPath.row)
                self.friendsList.remove(at: indexPath.row)
                self.friendsTableView.deleteRows(at: [indexPath], with: .fade)
            })
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            self.present(alertController, animated: true)
            
            completion(false)
        }
        
        delete.image = UIImage(named: "DeleteIcon")

        delete.backgroundColor =  UIColor(red: 0.2436070212, green: 0.5393256153, blue: 0.1766586084, alpha: 0)

        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false

        return config
    }
    
    func deleteFriendFirestore(row: Int) {
        let friendUuid = self.friendsList[row]
        if let currentUserUid = self.currentUserUid {
            self.userDocRef.updateData([
                "friendsList": FieldValue.arrayRemove([friendUuid])
            ])
            
            self.userCollectionRef.document(friendUuid).updateData([
                "friendsList": FieldValue.arrayRemove([currentUserUid])
            ])
            print("successfully removed friend \(friendUuid) from \(currentUserUid)")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateFriendsFirestore() {
        self.friendsList = [String]()
        
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
                    self.friendsList = friendUuids
                    self.friendsTableView.reloadData()
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

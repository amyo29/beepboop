//
//  FriendsViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    private var friendsList: [UserCustom] = []
    private let friendsTableViewCellIdentifier = "FriendsTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.friendsTableView)
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
    
        populateCell(friend: friend, cell: cell)
        
        return cell
    }
    
    func populateCell(friend: UserCustom, cell: FriendsTableViewCell) {
        print("in populateCell, friend=\(friend)")
        cell.friendNameLabel?.text = friend.userEmail
        cell.friendImageView?.image = UIImage(named: "EventPic") // change to friend user profile pic
    }
    
    @IBAction func friendMetadataButtonPressed(_ sender: Any) {
        
        let alertController = UIAlertController(
            title: "Edit settings for this friend",
            message: "Select action for this friend",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Remove",
                                    style: .cancel,
                                    handler: { (action) -> Void in
                                        
                                        print( "Remove friend from friends list and table view")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Block",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        
                                        print( "Block this user")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Edit",
                                    style: .default,
                                    handler: { (action) -> Void in
                                       
                                        print( "Edit friend")
                                    }))
        
       
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

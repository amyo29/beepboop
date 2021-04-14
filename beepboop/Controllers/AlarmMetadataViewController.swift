//
//  AlarmMetadataViewController.swift
//  beepboop
//
//  Created by Sanjana K on 4/13/21.
//

import UIKit

class AlarmMetadataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var declinedButton: UIButton!
    @IBOutlet weak var declinedLabel: UILabel!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var responseTableView: UITableView!
    
    private let responsesTableViewCellIdentifier = "ResponseTableViewCell"
    private var nameList: [Dictionary<String, Any>] = [[:]]
    private let acceptIcon = UIImage(named: "AcceptIcon")
    private let declinedIcon = UIImage(named: "DeclineIcon")
    private var curIcon = UIImage(named: "AcceptIcon")
//    var acceptedList: [String] = ["Harry", "Sally"]
//    var declinedList: [String] = ["Ryan", "Emma"]
//    var pendingList: [String] = ["Alvin", "Amy"]
    var acceptedList: [Dictionary<String, Any>] = [[:]]
    var declinedList: [Dictionary<String, Any>] = [[:]]
    var pendingList: [Dictionary<String, Any>] = [[:]]
    
    var time: String = "9:30AM"
    var alarmName: String = "iOS Class"
//    var confirmed:
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeLabel.text = self.time
        alarmNameLabel.text = self.alarmName
        
        self.responseTableView.delegate = self
        self.responseTableView.dataSource = self
        self.responseTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.responseTableView.separatorColor = .clear
        
        self.nameList = acceptedList
        print("nameList value: ", nameList)
        
        self.acceptedLabel.text = "Confirmed (\(self.acceptedList.count))"
        self.declinedLabel.text = "Declined (\(self.declinedList.count))"
        self.pendingLabel.text = "Pending (\(self.pendingList.count))"
        
        declinedButton.imageView?.alpha = 0.5
        declinedLabel.alpha = 0.5
        
        pendingButton.imageView?.alpha = 0.5
        pendingLabel.alpha = 0.5
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.responsesTableViewCellIdentifier, for: indexPath as IndexPath) as! ResponsesTableViewCell

        let friendName = String(describing: nameList[row]["name"]!)
        cell.friendName.text = friendName
        cell.friendProfileImage?.image = UIImage(named: "EventPic")
        cell.friendStatusImage?.image = curIcon
        
        return cell
    }
    
    @IBAction func onAcceptedEmojiPressed(_ sender: Any) {
        acceptedButton.imageView?.alpha = 1.0
        acceptedLabel.alpha = 1.0

        declinedButton.imageView?.alpha = 0.5
        declinedLabel.alpha = 0.5
        
        pendingButton.imageView?.alpha = 0.5
        pendingLabel.alpha = 0.5
        
        curIcon = acceptIcon
        nameList = acceptedList
        self.acceptedLabel.text = "Confirmed (\(self.acceptedList.count))"
        self.responseTableView?.reloadData()
    }
    
    @IBAction func onDeclinedEmojiPressed(_ sender: Any) {
        declinedButton.imageView?.alpha = 1.0
        declinedLabel.alpha = 1.0
        
        acceptedButton.imageView?.alpha = 0.5
        acceptedLabel.alpha = 0.5
        
        pendingButton.imageView?.alpha = 0.5
        pendingLabel.alpha = 0.5
        
        curIcon = declinedIcon
        nameList = declinedList
        self.declinedLabel.text = "Declined (\(self.declinedList.count))"
        self.responseTableView?.reloadData()
    }
    
    @IBAction func onPendingEmojiPressed(_ sender: Any) {
        pendingButton.imageView?.alpha = 1.0
        pendingLabel.alpha = 1.0
        
        declinedButton.imageView?.alpha = 0.5
        declinedLabel.alpha = 0.5
        
        acceptedButton.imageView?.alpha = 0.5
        acceptedLabel.alpha = 0.5
        
        curIcon = UIImage(named: "NotificationAlert")
        nameList = pendingList
        self.pendingLabel.text = "Pending (\(self.pendingList.count))"
        self.responseTableView?.reloadData()
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

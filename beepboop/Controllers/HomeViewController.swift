//
//  HomeViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/17/21.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmTableView: UITableView!
    
    private var alarms: [Alarm] = []
    
    private let alarmTableViewCellIdentifier = "AlarmTableViewCell"
    
    var userEmail: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        titleLabel.font = UIFont(name: "JosefinSans-Light", size: 40.0)
        
        let fontFamilyNames = UIFont.familyNames
            for familyName in fontFamilyNames {
                print("Font Family Name = [\(familyName)]")
                let names = UIFont.fontNames(forFamilyName: familyName as String)
                print("Font Names = [\(names)]")
            }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.sendSubviewToBack(self.alarmTableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmTableViewCellIdentifier, for: indexPath as IndexPath) as! AlarmTableViewCell
        
        cell.alarmNameLabel?.text = self.alarms[row].name
        cell.alarmTimeLabel?.text = self.alarms[row].time
        cell.alarmImageView?.image = UIImage(named: "../Resources/Images/EventPic.png")
        
        return cell
    }
}


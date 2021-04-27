//
//  GroupViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/25/21.
//

import UIKit

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var groupsList: [GroupCustom] = []
    private let groupTableViewCellIdentifier = "GroupTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        self.groupTableView.backgroundColor = UIColor(hex: "FEFDEC")
        self.groupTableView.separatorColor = .clear

        // Do any additional setup after loading the view.
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.groupTableView)
        self.populateGroupTableWithDummyValues()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.groupTableViewCellIdentifier, for: indexPath as IndexPath) as! GroupTableViewCell
        
        let group = self.groupsList[row]
        
        self.populateCell(group: group, cell: cell)
        self.colourCell(group: group, cell: cell, row: row)
                
        return cell
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// set animation variables
        let duration = 0.5
        let delayFactor = 0.05
        let rowHeight: CGFloat = 62
        
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
    
    func populateCell(group: GroupCustom, cell: GroupTableViewCell) {
        cell.groupNameLabel?.text = group.name
        cell.groupNameLabel?.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        cell.groupImageView?.image = UIImage(named: "GroupPic")
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func colourCell(group: GroupCustom, cell: GroupTableViewCell, row: Int) {
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
        
        let cellColours = [tiffanyBlue, doveEggBlue, lavender, lilac, babyPink, rose, orangeGold, softYellow, lightGreen, pastelGreen]
        let frequency = row % cellColours.count
        cell.contentView.backgroundColor = cellColours[frequency]
    }
    
    func populateGroupTableWithDummyValues() {
        self.groupsList = []
        self.groupsList.append(GroupCustom(name: "ball is life"))
        self.groupsList.append(GroupCustom(name: "scotts tots"))
        self.groupsList.append(GroupCustom(name: "bulko fan club"))
        self.groupsList.append(GroupCustom(name: "haikyuu watch party"))
        self.groupTableView?.reloadData()
    }
    

    @IBAction func groupMetadataButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Edit settings for this friend",
            message: "Select action for this friend",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Remove",
                                    style: .destructive,
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
        
        alertController.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: { (action) -> Void in
                                    }))
        
       
        self.present(alertController, animated: true, completion: nil)
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

//
//  AlarmTableViewCell.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/26/21.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var alarmImageView: UIImageView!
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var alarmToggleSwitch: UISwitch!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            // Make it card-like
            containerView.layer.cornerRadius = 10
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowRadius = 2
            containerView.layer.shadowColor = UIColor(named: "Orange")?.cgColor
            containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
            containerView.backgroundColor = UIColor(named: "Red")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

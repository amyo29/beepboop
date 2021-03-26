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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

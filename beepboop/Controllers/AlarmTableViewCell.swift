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
    @IBOutlet weak var alarmDateLabel: UILabel!
    @IBOutlet weak var alarmToggleSwitch: UISwitch!
    
//    @IBOutlet weak var containerView: UIView! {
//        didSet {
//            // Make it card-like
//            containerView.layer.cornerRadius = 10
//            containerView.layer.shadowOpacity = 1
//            containerView.layer.shadowRadius = 2
//            containerView.layer.shadowColor = UIColor(named: "Orange")?.cgColor
//            containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
//            containerView.backgroundColor = UIColor(named: "Red")
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.layer.cornerRadius = 25
        contentView.backgroundColor = .white
        
        // this will turn on `masksToBounds` just before showing the cell
        contentView.layer.masksToBounds = true
        
        // add shadow on cell
        backgroundColor = UIColor(hex: "FEFDEC") // very important
        contentView.layer.masksToBounds = false
        contentView.layer.shadowOpacity = 0.23
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        contentView.frame = contentView.frame.inset(by: margins)
    }

}

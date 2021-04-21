//
//  ShareToFriendsTableViewCell.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/12/21.
//

import UIKit

class ShareToFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    
    
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

    @IBAction func shareButtonPressed(_ sender: Any) {
    }
}

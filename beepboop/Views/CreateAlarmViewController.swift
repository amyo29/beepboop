//
//  CreateAlarmViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/27/21.
//

import UIKit

class CreateAlarmViewController: UIViewController {

    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var soundPickerView: UIPickerView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        screenTitleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        timeLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        dateLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        repeatLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        soundLabel.font = UIFont(name: "JosefinSans-Regular", size: 20.0)
        
        // set title of alarm to user entered text
        let alarmTitle = titleTextField.text
        
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
        // add new alarm to core data
        // storeAlarmEntity()
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

//
//  CreateAlarmViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/27/21.
//

import UIKit

class CreateAlarmViewController: UIViewController {
    
    // MARK: - Properties
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
    
    // MARK: - Views
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
    
    // MARK: Button actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        // add new alarm to core data
        // storeAlarmEntity()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // transition to share to contacts popover/screen
    }
    
    // MARK: Hide keyboard
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

//
//  CreateAlarmViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/27/21.
//

import UIKit

class CreateAlarmViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    @IBOutlet weak var repeatButton: UIButton!
    
    private let sounds = ["beep", "boop", "chirp", "wake up"]
    private var repeatTimes:String? = nil
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundPickerView.delegate = self
        soundPickerView.dataSource = self

        // Do any additional setup after loading the view.
        screenTitleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        timeLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        dateLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        soundLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        repeatButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        shareButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:titleTextField.frame.height - 1), size: CGSize(width: titleTextField.frame.width, height:  1))
        bottomLine.backgroundColor = UIColor.black.cgColor
        titleTextField.borderStyle = UITextField.BorderStyle.none
        titleTextField.layer.addSublayer(bottomLine)
        
        // set title of alarm to user entered text
        let alarmTitle = titleTextField.text
        
    }
    
    // set repeat occurrences in the form of an Alert Action Sheet
    @IBAction func repeatButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Repeat",
            message: "Select repeating times for this alarm",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Hourly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        self.repeatTimes = "Hourly"
                                        print( "Hourly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Daily",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        self.repeatTimes = "Daily"
                                        print( "Daily")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Weekly - select days",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        self.repeatTimes = "Weekly"
                                        print( "Weekly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Monthly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        self.repeatTimes = "Monthly"
                                        print( "Monthly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Yearly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        self.repeatTimes = "Yearly"
                                        print( "Yearly")
                                    }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Picker View functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sounds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sounds[row]
    }
    
    // MARK: - Button actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        // add new alarm to core data
        // storeAlarmEntity()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // transition to share to contacts popover/screen
    }
    
    // MARK: - Hide keyboard
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

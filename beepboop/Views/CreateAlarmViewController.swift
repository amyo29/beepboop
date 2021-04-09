//
//  CreateAlarmViewController.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/27/21.
//

import UIKit

class CreateAlarmViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()
    
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
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var snoozeLabel: UILabel!
    
    private let sounds = ["beep", "boop", "chirp", "wake up"]
    private var recurring: String = "Never"
    private let createAlarmToHomeSegueIdentifier = "CreateAlarmToHomeSegueIdentifier"
   
    var delegate: UIViewController!
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundPickerView.delegate = self
        soundPickerView.dataSource = self

        // Do any additional setup after loading the view.
        screenTitleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        timeLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        titleTextField.font = UIFont(name: "JosefinSans-Regular", size: 25.0)
//        let aquablue = UIColor(hex: "#00ffff")
//        titleTextField.textColor = UIColor(red:0/255, green:128/255, blue:255/255, alpha:1.0) // aqua
//        titleTextField.textColor = UIColor(red:0/255, green:255/255, blue:255/255, alpha:1.0) // turquoise
        titleTextField.textColor = UIColor(red:31/255, green:207/255, blue:245/255, alpha:1.0) // figma blue colour title
        dateLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        soundLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        snoozeLabel.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        repeatButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        repeatButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        shareButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:titleTextField.frame.height - 1), size: CGSize(width: titleTextField.frame.width, height:  1))
        bottomLine.backgroundColor = UIColor.black.cgColor
        titleTextField.borderStyle = UITextField.BorderStyle.none
        titleTextField.layer.addSublayer(bottomLine)
                
//        // set listener for datePicker
//        self.datePicker.addTarget(self, action: #selector(self.datePickerChanged(picker:)), for: .valueChanged)
//
//        // set listener for timePicker
//        self.timePicker.addTarget(self, action: #selector(self.timePickerChanged(picker:)), for: .valueChanged)
    }
        
    // set repeat occurrences in the form of an Alert Action Sheet
    @IBAction func repeatButtonPressed(_ sender: UIButton) {
        repeatButton.titleLabel?.font = UIFont(name: "JosefinSans-Regular", size: 30.0)
        let attributedTitle = sender.attributedTitle(for: .normal)
            
        
        let alertController = UIAlertController(
            title: "Repeat",
            message: "Select repeating times for this alarm",
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
                                    title: "Hourly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Hourly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle("Hourly", for: .normal)
                                        self.recurring = "Hourly"
                                        print( "Hourly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Daily",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Daily", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Daily" , for: .normal )
                                        self.recurring = "Daily"
                                        print( "Daily")
                                    }))
        
        // TODO: consider adding selecting days of the week back in
        alertController.addAction(UIAlertAction(
                                    title: "Weekly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Weekly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Weekly" , for: .normal )
                                        self.recurring = "Weekly"
                                        print( "Weekly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Monthly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Monthly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Monthly" , for: .normal )
                                        self.recurring = "Monthly"
                                        print( "Monthly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Yearly",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Yearly", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Yearly" , for: .normal )

                                        self.recurring = "Yearly"
                                        print( "Yearly")
                                    }))
        
        alertController.addAction(UIAlertAction(
                                    title: "Never",
                                    style: .default,
                                    handler: { (action) -> Void in
                                        attributedTitle?.setValue("Never", forKey: "string")
                                        sender.setAttributedTitle(attributedTitle, for: .normal)
                                        self.repeatButton.setTitle( "Never" , for: .normal )
                                        self.recurring = "Never"
                                        print( "Never")
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
        if let time = self.timePicker?.date,
           let date = self.datePicker?.date,
           let mergedDate = self.combineDateWithTime(date: date, time: time),
           let title = self.titleTextField.text,
           let _ = self.delegate as? HomeViewController {
            let homeViewController = self.delegate as! AlarmAdder
            homeViewController.addAlarm(time: mergedDate, name: title, recurrence: recurring)
        } else {
            print("Something went wrong when save button pressed")
        }
        
        self.performSegue(withIdentifier: self.createAlarmToHomeSegueIdentifier, sender: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // transition to share to contacts popover/screen
        print("shareButtonPressed")
    }
    
    // MARK: - Hide keyboard
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Utility
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateSelected = calendar.dateComponents([.year, .month, .day], from: date)
        let timeSelected = calendar.dateComponents([.hour, .minute, .second], from: time)

        var mergedComponents = DateComponents()
        mergedComponents.year = dateSelected.year
        mergedComponents.month = dateSelected.month
        mergedComponents.day = dateSelected.day
        mergedComponents.hour = timeSelected.hour
        mergedComponents.minute = timeSelected.minute
        mergedComponents.second = timeSelected.second

        return calendar.date(from: mergedComponents)
    }
}

extension UIViewController {

    func presentDetail(_ createAlarmViewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)

        present(createAlarmViewController, animated: false)
    }

    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

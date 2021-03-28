//
//  HomeViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/17/21.
//

import UIKit
import CoreData

protocol AlarmAdder {
    func addAlarm(time: Date, date: Date, name: String, recurrence: String)
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmAdder{

    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmTableView: UITableView!
    
    // data source of stored alarms per user
    private var alarms: [Alarm] = []
    
    private let alarmTableViewCellIdentifier = "AlarmTableViewCell"
    
    var userEmail: String?

    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.alarmTableView.delegate = self
        self.alarmTableView.dataSource = self
        
//        self.navigationController?.isNavigationBarHidden = false
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
        // customize tab bar items
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "JosefinSans-Regular", size: 20)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: [])
        // load system supported fonts to determine system font labels
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
//                print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName as String)
//                print("Font Names = [\(names)]")
        }
        self.updateAlarmList()
        print("alarms count: ", self.alarms.count)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.sendSubviewToBack(self.alarmTableView)
    }
    
    // MARK: - Table View functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("In tableView count method, count: ", self.alarms.count)
        return self.alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In tableView cell render method, count: ", self.alarms.count)
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmTableViewCellIdentifier, for: indexPath as IndexPath) as! AlarmTableViewCell
        
//        cell.alarmNameLabel?.text = self.alarms[row].name
//        cell.alarmTimeLabel?.text = self.alarms[row].time
        cell.alarmImageView?.image = UIImage(named: "../Resources/Images/EventPic.png")
        cell.alarmNameLabel?.text = "Exam"
        cell.alarmTimeLabel?.text = "9:30AM"

//        let imageName = UIImage(named: transportItems[indexPath.row])
//        cell.imageView?.image = imageName
        
        return cell
    }
    
//    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        // add shadow on cell
//        backgroundColor = .clear // very important
//        layer.masksToBounds = false
//        layer.shadowOpacity = 0.23
//        layer.shadowRadius = 4
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowColor = UIColor.blackColor().CGColor
//
//        // add corner radius on `contentView`
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 8
//    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        
        // add shadow on cell
        cell.backgroundColor = .clear // very important
        cell.contentView.layer.masksToBounds = false
        cell.contentView.layer.shadowOpacity = 0.23
        cell.contentView.layer.shadowRadius = 4
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.contentView.layer.shadowColor = UIColor.black.cgColor

        // add corner radius on `contentView`
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 8
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    // MARK: - Delegate functions
    
    func addAlarm(time: Date, date: Date, name: String, recurrence: String) {
        self.addAlarmToCoreData(time: time, date: date, name: name, recurrence: recurrence)
        self.updateAlarmList()
    }
    
    // MARK: - CoreData functions
    
    func addAlarmToCoreData(time: Date, date: Date, name: String, recurrence: String) {
        // store new Alarm in CoreData
        // Alarm is user-specific
        print("adding alarm to coredata")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alarm = NSEntityDescription.insertNewObject(forEntityName: "Alarm", into: context)
        
//        alarm.setValue(self.userEmail, forKey: "userEmail")
        alarm.setValue(UUID(), forKey: "uuid")
        alarm.setValue("Testing", forKey: "time")
        alarm.setValue(date, forKey: "date")
        alarm.setValue(name, forKey: "name")
        alarm.setValue(recurrence, forKey: "recurring")
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
            abort()
        }
    }
    
    func updateAlarmList() {
        // update data source
        print("in update alarm list, number of alarms: ", self.alarms.count)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alarm")
        var fetchedResults: [Alarm]? = [Alarm]()
        
//        request.predicate = NSPredicate(format: "userEmail == %@", self.userEmail! as NSString)
        
        do {
            try fetchedResults = context.fetch(request) as? [Alarm]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        self.alarms = fetchedResults ?? self.alarms
        print("in update alarm list, number of alarms: ", self.alarms.count)
        self.alarmTableView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateAlarmViewController{
//            let trans = CATransition()
//            trans.type = CATransitionType.moveIn
//            trans.subtype = CATransitionSubtype.fromLeft
//            trans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//            trans.duration = 0.35
//            self.navigationController?.view.layer.add(trans, forKey: nil)
            destination.delegate = self
        }
    }
}


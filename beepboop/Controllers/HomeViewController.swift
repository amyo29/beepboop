//
//  HomeViewController.swift
//  beepboop
//
//  Created by Alvin Lo on 3/17/21.
//

import UIKit
import CoreData

protocol AlarmAdder {
    func addAlarm(time: Date, date: Date, name: String, recurring: String)
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmAdder{

    // MARK: - Properties
    var alarmScheduler: ScheduleAlarmDelegate = ScheduleAlarm()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alarmTableView: UITableView!
    
    // data source of stored alarms per user
    private var alarms: [Alarm] = []
    
    private let alarmTableViewCellIdentifier = "AlarmTableViewCell"
    
    // TODO: add back userEmail functionality
//    var userEmail: String?

    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        clearCoreData()
        self.alarmTableView.delegate = self
        self.alarmTableView.dataSource = self
        
        titleLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
        
        // customize tab bar items
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "JosefinSans-Regular", size: 20)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: [])
        
        // loadSystemSupportedFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.sendSubviewToBack(self.alarmTableView)
        self.updateAlarmList()
        print("alarms count: ", self.alarms.count)
    }
    
    // load system supported fonts to determine system font labels
    func loadSystemSupportedFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName as String)
            print("Font Names = [\(names)]")
        }
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
        
        cell.alarmNameLabel?.text = self.alarms[row].name
        cell.alarmTimeLabel?.text = self.extractTimeFromDate(time: self.alarms[row].time)
        cell.alarmDateLabel?.text = self.extractDate(time: self.alarms[row].time)
        cell.alarmToggleSwitch?.tag = row
        cell.alarmImageView?.image = UIImage(named: "EventPic")
        
        return cell
    }
    
    // Remove alarm from table view by swiping to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if editingStyle == .delete {
            // Delete notifications
            if let uuid = self.alarms[indexPath.row].uuid {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid.uuidString])
            }
            
            // Delete Alarm Entity (NSManagedObject) from alarms list
            context.delete(alarms[indexPath.row])
            alarms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Commit the changes
            do {
                try context.save()
            } catch {
                // if an error occurs
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alarm")
        request.predicate = NSPredicate(format: "uuid == %@", self.alarms[index].uuid! as NSUUID)
        
        // Update enable value
        do {
            if let fetchedResults = try context.fetch(request) as? [Alarm],
               fetchedResults.count > 0 {
                fetchedResults[0].setValue(sender.isOn, forKey: "enabled")
            }
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        // Enable/Disable notifications
        let alarm = self.alarms[index]
        if sender.isOn {
            if let name = alarm.name,
               let time = alarm.time,
               let recurring = alarm.recurring,
               let uuid = alarm.uuid {
                alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurring, uuid: uuid)
            }
        } else {
            if let uuid = alarm.uuid {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid.uuidString])
            }
        }
    }
    
    // Customize table view cell
    func tableView(_ tableView: UITableView, willDisplay cell: AlarmTableViewCell, forRowAt indexPath: IndexPath) {
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
    
    func addAlarm(time: Date, date: Date, name: String, recurring: String) {
        self.addAlarmToCoreData(time: time, date: date, name: name, recurring: recurring)
        self.updateAlarmList()
    }
    
    // MARK: - CoreData functions
    
    func addAlarmToCoreData(time: Date, date: Date, name: String, recurring: String) {
        // store new Alarm in CoreData
        // Alarm is user-specific
        print("adding alarm to coredata")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alarm = NSEntityDescription.insertNewObject(forEntityName: "Alarm", into: context)
        let uuid = UUID()
        alarm.setValue(uuid, forKey: "uuid")
        alarm.setValue(time, forKey: "time")
        alarm.setValue(date, forKey: "date")
        alarm.setValue(name, forKey: "name")
        alarm.setValue(recurring, forKey: "recurring")
        alarm.setValue(true, forKey: "enabled")
        alarm.setValue(true, forKey: "snoozeEnabled")
        
        alarmScheduler.setNotificationWithTimeAndDate(name: name, time: time, recurring: recurring, uuid: uuid)
        
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
        
        self.alarms = fetchedResults ?? [Alarm]()
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
    
    // MARK: - Utility
    func extractTimeFromDate(time: Date?) -> String {
        if let time = time {
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: time)
            let minutes = calendar.component(.minute, from: time)
            if hour >= 12 {
                if hour > 12 {
                    hour -= 12
                }
                return String(format: "%d:%0.2d PM", hour, minutes)
            } else {
                if hour == 0 {
                    hour = 12
                }
                return String(format: "%d:%0.2d AM", hour, minutes)
            }
        } else {
            return "Error when extracting time from Date object"
        }
    }
    
    func extractDate(time: Date?) -> String {
        if let time = time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, MMM d"
            return dateFormatter.string(from: time)
        } else {
            return "Error when extracting date from Date object"
        }
    }
    
    
    func clearCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alarm")
        
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                    print("\(result.value(forKey:"name")!) has been deleted")
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        
    }
}


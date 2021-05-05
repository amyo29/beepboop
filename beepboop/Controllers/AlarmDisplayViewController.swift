//
//  AlarmDisplayViewController.swift
//  beepboop
//
//  Created by Sanjana K on 4/26/21.
//

import UIKit
import Firebase
import CoreData

class AlarmDisplayViewController: UIViewController {
    @IBOutlet weak var alarmNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var alarmID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        populateInfo()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        var darkmode = false
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                try fetchedResults = context.fetch(fetchRequest) as! [NSManagedObject]
                darkmode = fetchedResults[0].value(forKey: "darkmodeEnabled") as! Bool
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if darkmode {
            self.view.backgroundColor = UIColor(rgb: 0x262221)
            overrideUserInterfaceStyle = .dark

        }
        else {
            self.view.backgroundColor = UIColor(rgb: 0xFEFDEC)
            overrideUserInterfaceStyle = .light
        }
    }
    
    func populateInfo() {
        if alarmID != "" {
            print("Finding \(alarmID)")
            let alarmCollectionRef = Firestore.firestore().collection("alarmData")
            alarmCollectionRef.document(alarmID).getDocument { (alarmDoc, error) in
                guard let alarmDoc = alarmDoc, alarmDoc.exists else {
                    print("Could not find alarm \(String(describing: error))")
                    return
                }
                let alarmName = alarmDoc.get("name") as! String
                self.alarmNameLabel.text = alarmName
                self.alarmNameLabel.font = UIFont(name: "JosefinSans-Regular", size: 40.0)
                let time = self.extractTimeFromDate(time: alarmDoc.get("time") as? Timestamp)
                self.timeLabel.text = time
                self.timeLabel.font = UIFont(name: "JosefinSans-Regular", size: 50.0)
            }
        }
    }
    
    @IBAction func acceptAlarmOnClick(_ sender: Any) {
        performSegue(withIdentifier: "alarmToHome", sender: self)
    }
    
    @IBAction func declineAlarmOnClick(_ sender: Any) {
        performSegue(withIdentifier: "alarmToHome", sender: self)
    }
    
    @IBAction func snoozeAlarmOnClick(_ sender: Any) {
        performSegue(withIdentifier: "alarmToHome", sender: self)
    }
    
    @IBAction func metadataOnClick(_ sender: Any) {
        performSegue(withIdentifier: "AlarmDisplayToMetadataIdentifier", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AlarmDisplayToMetadataIdentifier", let destination = segue.destination as? AlarmMetadataViewController {
            // TODO: modify alarm metadata screen to accept either alarmID or userStatus
            destination.alarmID = alarmID
        } 
    }
    
    func extractTimeFromDate(time: Timestamp?) -> String {
        if let time = time?.dateValue() {
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
}

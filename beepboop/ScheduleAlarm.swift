//
//  ScheduleAlarm.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/29/21.
//

import Foundation
import UIKit

class ScheduleAlarm : ScheduleAlarmDelegate {
    
    func setNotificationWithTimeAndDate(name: String, time: Date, recurring: String, uuid: UUID) {
        print("here at start of notification function")
        let timeDisplay = extractTimeFromDate(time: time)
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = "Repeats \(recurring) at \(timeDisplay)"
        content.sound = .default
        
        let calendar = Calendar.current
        print(calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time))
        
        let timeSelected = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time)
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: timeSelected, repeats: true)
        
        // Create the request
        let uuidString = uuid.uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
                print(error!.localizedDescription)
           }
        }
        print("here at end of notification function")
        //  To cancel an active notification request, call the removePendingNotificationRequests(withIdentifiers:) method of UNUserNotificationCenter.
        
    }
    
    func extractTimeFromDate(time: Date?) -> String {
        let calendar = Calendar.current
        if let time = time {
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

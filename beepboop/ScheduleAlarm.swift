//
//  ScheduleAlarm.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/29/21.
//

import Foundation
import UIKit

enum RepeatInterval: String {
    case Never = "Never"
    case Hourly = "Hourly"
    case Daily = "Daily"
    case Weekly = "Weekly"
    case Monthly = "Monthly"
    case Yearly = "Yearly"
    
    static let allValues = [Never, Hourly, Daily, Weekly, Monthly, Yearly]
    
    func retrieveRepeatInterval(time: Date) -> DateComponents {
        let calendar = Calendar.current
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time)

        switch self {
        case .Never:
            break
        case .Hourly:
            component = calendar.dateComponents([.minute], from: time)
        case .Daily:
            component = calendar.dateComponents([.hour, .minute], from: time)
        case .Weekly:
            component = calendar.dateComponents([.hour, .minute, .weekday], from: time)
        case .Monthly:
            component = calendar.dateComponents([.hour, .minute, .day], from: time)
        case .Yearly:
            component = calendar.dateComponents([.hour, .minute, .day, .month], from: time)
        }
        
        component.second = 0
        return component
    }
}

class ScheduleAlarm : ScheduleAlarmDelegate {
    
    func setNotificationWithTimeAndDate(name: String, time: Date, recurring: String, uuidStr: String) {
        guard let repeatInterval = RepeatInterval(rawValue: recurring) else {
            print("Recurring value cannot be mapped")
            abort()
        }
        
        let timeDisplay = extractTimeFromDate(time: time)
        
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = "Repeats \(recurring) at \(timeDisplay)"
        content.sound = .default
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: repeatInterval.retrieveRepeatInterval(time: time), repeats: repeatInterval != RepeatInterval.Never)
        
        // Create the request
        let request = UNNotificationRequest(identifier: uuidStr,
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

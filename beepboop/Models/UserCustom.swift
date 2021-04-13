//
//  User.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

import Foundation
import Firebase
import FirebaseFirestore

struct UserCustom {
    var userEmail: String?
    var name: String?
//    var alarmData: [[String: Any]]?
    // groups
    var snoozeEnabled: Bool?
    var darkModeEnabled: Bool?
    var friendRequestsReceived: [String]?
    var friendRequestsSent: [String]?
    var friendsList: [String]?
    var alarmRequestsReceived: [String]?
    var alarmRequestsSent: [String]?
    var notifications: [[String: Any]]?
    
    
    var dictionary: [String: Any] {
        return [
            "userEmail": self.userEmail ?? "",
            "name": self.name ?? "",
//            "alarmData": self.alarmData ?? [],
            "snoozeEnabled": self.snoozeEnabled ?? false,
            "darkModeEnabled": self.darkModeEnabled ?? false,
            "friendRequestsReceived": self.friendRequestsReceived ?? [],
            "friendRequestsSent": self.friendRequestsSent ?? [],
            "friendsList": self.friendsList ?? [],
            "alarmRequestsReceived": self.alarmRequestsReceived ?? [],
            "alarmRequestsSent": self.alarmRequestsSent ?? [],
            "notifications": self.notifications ?? []
        ]
    }
}


extension UserCustom {
    init?(dictionary: [String : Any]) {
        guard let userEmail = dictionary["userEmail"] as? String,
              let name = dictionary["name"] as? String,
//              let alarmData = dictionary["alarmData"] as? [[String: Any]],
              let snoozeEnabled = dictionary["snoozeEnabled"] as? Bool,
              let darkModeEnabled = dictionary["darkModeEnabled"] as? Bool,
              let friendRequestsReceived = dictionary["friendRequestsReceived"] as? [String],
              let friendRequestsSent = dictionary["friendRequestsSent"] as? [String],
              let friendsList = dictionary["friendsList"] as? [String],
              let alarmRequestsReceived = dictionary["alarmRequestsReceived"] as? [String],
              let alarmRequestsSent = dictionary["alarmRequestsSent"] as? [String],
              let notifications = dictionary["notifications"] as? [[String: Any]]
        else { return nil }
        
        self.init(userEmail: userEmail,
                  name: name,
//                  alarmData: alarmData,
                  snoozeEnabled: snoozeEnabled,
                  darkModeEnabled: darkModeEnabled,
                  friendRequestsReceived: friendRequestsReceived,
                  friendRequestsSent: friendRequestsSent,
                  friendsList: friendsList,
                  alarmRequestsReceived: alarmRequestsReceived,
                  alarmRequestsSent: alarmRequestsSent,
                  notifications: notifications
        )
    }
}

//
//  User.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/11/21.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User {
    var userId: String?
    var alarmData: [[String: Any]]?
    // groups
    var snoozeEnabled: Bool?
    var darkModeEnabled: Bool?
    var friendRequestsReceived: [String]?
    var friendRequestsSent: [String]?
    
    
    var dictionary: [String: Any] {
        return [
            "userId": self.userId ?? UUID().uuidString,
            "alarmData": self.alarmData ?? [],
            "snoozeEnabled": self.snoozeEnabled ?? false,
            "darkModeEnabled": self.darkModeEnabled ?? false,
            "friendRequestsReceived": self.friendRequestsReceived ?? [],
            "friendRequestsSent": self.friendRequestsSent ?? []
        ]
    }
}


extension User {
    init?(dictionary: [String : Any]) {
        guard let userId = dictionary["userId"] as? String,
              let alarmData = dictionary["alarmData"] as? [[String: Any]],
              let snoozeEnabled = dictionary["snoozeEnabled"] as? Bool,
              let darkModeEnabled = dictionary["darkModeEnabled"] as? Bool,
              let friendRequestsReceived = dictionary["friendRequestsReceived"] as? [String],
              let friendRequestsSent = dictionary["friendRequestsSent"] as? [String]
              
              
        else { return nil }
        
        self.init(userId: userId,
                  alarmData: alarmData,
                  snoozeEnabled: snoozeEnabled,
                  darkModeEnabled: darkModeEnabled,
                  friendRequestsReceived: friendRequestsReceived,
                  friendRequestsSent: friendRequestsSent
        )
    }
}

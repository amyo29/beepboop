//
//  AlarmCustom.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/8/21.
//

import Foundation
import Firebase
import FirebaseFirestore

struct AlarmCustom {
    var name: String?
    var time: Date?
    var recurrence: String?
//    var enabled: Bool?
//    var snoozeEnabled: Bool?
    var uuidStr: String?
    var userId: [String]?
    
    var dictionary: [String: Any] {
        return [
            "name": self.name ?? "None",
            "time": self.time ?? NSDate.distantPast,
            "recurrence": self.recurrence ?? "Never",
//            "enabled": self.enabled ?? false,
//            "snoozeEnabled": self.snoozeEnabled ?? false,
            "uuid": self.uuidStr ?? UUID().uuidString,
            "userId": self.userId ?? UUID().uuidString
        ]
    }
}

//class AlarmCustom {
//
//    public var name: String?
//    public var time: Date?
//    public var recurrence: String?
//    public var enabled: Bool?
//    public var snoozeEnabled: Bool?
//    public var uuidStr: String?
//
//    init (name: String, time: Date, recurrence: String, enabled: Bool, snoozeEnabled: Bool, uuidStr: String) {
//        self.name = name
//        self.time = time
//        self.recurrence = recurrence
//        self.enabled = enabled
//        self.snoozeEnabled = snoozeEnabled
//        self.uuidStr = uuidStr
//    }
//
//    func convertToDict() -> [String: Any] {
//        return [
//            "name": self.name ?? "None",
//            "time": self.time ?? NSDate.distantPast,
//            "recurrence": self.recurrence ?? "Never",
//            "enabled": self.enabled ?? false,
//            "snoozeEnabled": self.snoozeEnabled ?? false,
//            "uuid": self.uuidStr ?? UUID().uuidString
//        ]
//    }
//}

extension AlarmCustom {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let timestamp = dictionary["time"] as? Timestamp,
              let recurrence = dictionary["recurrence"] as? String,
//              let enabled = dictionary["enabled"] as? Bool,
//              let snoozeEnabled = dictionary["snoozeEnabled"] as? Bool,
              let uuidStr = dictionary["uuid"] as? String,
              let userId = dictionary["userId"] as? [String]
        else { return nil }
        
        self.init(name: name,
                  time: timestamp.dateValue(),
                  recurrence: recurrence,
//                  enabled: enabled,
//                  snoozeEnabled: snoozeEnabled,
                  uuidStr: uuidStr,
                  userId: userId
        )
    }
}

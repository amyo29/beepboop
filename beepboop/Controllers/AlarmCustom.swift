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
    var sound: String?
    var uuid: String?
    var userList: [String]?
    var userStatus: [String: String]?
    
    var dictionary: [String: Any] {
        return [
            "name": self.name ?? "None",
            "time": self.time ?? NSDate.distantPast,
            "recurrence": self.recurrence ?? "Never",
            "sound": self.sound ?? "None",
            "uuid": self.uuid ?? UUID().uuidString,
            "userList": self.userList ?? [],
            "userStatus": self.userStatus ?? []
        ]
    }
}

extension AlarmCustom {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let timestamp = dictionary["time"] as? Timestamp,
              let recurrence = dictionary["recurrence"] as? String,
              let sound = dictionary["sound"] as? String,
              let uuid = dictionary["uuid"] as? String,
              let userList = dictionary["userList"] as? [String],
              let userStatus = dictionary["userStatus"] as? [String: String]
        else { return nil }
        
        self.init(name: name,
                  time: timestamp.dateValue(),
                  recurrence: recurrence,
                  sound: sound,
                  uuid: uuid,
                  userList: userList,
                  userStatus: userStatus
        )
    }
}

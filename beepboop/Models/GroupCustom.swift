//
//  GroupCustom.swift
//  beepboop
//
//  Created by Alvin Lo on 4/25/21.
//

import Foundation
import Firebase
import FirebaseFirestore

struct GroupCustom {
    var name: String?
    var members: [String]?
    var alarms: [String]?
    var uuid: String?
    
    var dictionary: [String: Any] {
        return  [
            "name": self.name ?? "",
            "members": self.members ?? [],
            "alarms": self.alarms ?? [],
            "uuid": self.uuid ?? ""
        ]
    }
}

extension GroupCustom {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let members = dictionary["members"] as? [String],
              let alarms = dictionary["alarms"] as? [String],
              let uuid = dictionary["uuid"] as? String
        else { return nil }
        
        self.init(name: name, members: members, alarms: alarms, uuid: uuid)
    }
}



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
    
    var dictionary: [String: Any] {
        return  [
            "name": self.name ?? ""
        ]
    }
}

extension GroupCustom {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else {
            return nil
        }
        
        self.init(name: name)
    }
}



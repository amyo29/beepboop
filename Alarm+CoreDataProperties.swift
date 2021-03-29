//
//  Alarm+CoreDataProperties.swift
//  
//
//  Created by Alvin Lo on 3/26/21.
//
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm")
    }

    @NSManaged public var time: String?
    @NSManaged public var name: String?
    @NSManaged public var recurring: String?
    @NSManaged public var date: Date?
    @NSManaged public var uuid: UUID?
//    @NSManaged public var enabled: Bool
//    @NSManaged public var snoozeEnabled: Bool

}

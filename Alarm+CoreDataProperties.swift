//
//  Alarm+CoreDataProperties.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/29/21.
//
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm")
    }

    @NSManaged public var date: Date?
    @NSManaged public var enabled: Bool
    @NSManaged public var name: String?
    @NSManaged public var recurring: String?
    @NSManaged public var snoozeEnabled: Bool
    @NSManaged public var time: Date?
    @NSManaged public var uuid: UUID?

}

extension Alarm : Identifiable {

}

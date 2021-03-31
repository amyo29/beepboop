//
//  ScheduleAlarmDelegate.swift
//  beepboop
//
//  Created by Amy Ouyang on 3/29/21.
//

import Foundation
import UIKit

protocol ScheduleAlarmDelegate {
    func setNotificationWithTimeAndDate(name: String, time: Date, recurring: String, uuid: UUID)
}

//
//  Notifications.swift
//  alarm
//
//  Created by Ernest on 02/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let saveAlarm = Notification.Name("saveAlarm")
    static let saveGroup = Notification.Name("saveAddingGroupAlarmToGroup")

    static let addedGroup = Notification.Name("addedGroup")

    static let openclose = Notification.Name("openclose")


    static let SnoozeAndStop = "SNOOZE_AND_STOP"
    static let StopOnly = "STOP_ONLY"
}

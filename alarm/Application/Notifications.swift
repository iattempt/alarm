//
//  Notifications.swift
//  alarm
//
//  Created by Ernest on 02/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let openclose = Notification.Name("openclose")

    static let SnoozeAndStopCategory = "SnoozeAndStopCategory"
    static let StopOnlyCategory = "StopOnlyCategory"
    static let AlarmStopAction = "AlarmStopAction"
    static let AlarmSnoozeAction = "AlarmSnoozeAction"
}

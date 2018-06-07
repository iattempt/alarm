//
//  AlarmProtocol.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation

protocol AlarmProtocol {
    var alarmId: Int {get set}
    var enabled: Bool {get set}
    var label: String {get set}
    var date: Date {get set}
    // nil as disabled
    var soundId: Int? {get set}
    var vibrateId: Int? {get set}
    var snoozeId: Int? {get set}
    var doesBelongToGroup: String? {get set}
}

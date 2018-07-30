//
//  Alarm.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation
import MediaPlayer

var NextAlarmId: Int = 0

// this can be treated as viewModel
struct Alarm: Codable {
    var alarmId: Int = 0
    var alarmLabel: String = "Alarm"
    var groupId: Int? = nil
    var enabled: Bool = false
    var date: Date = Date()
    var soundId: MPMediaEntityPersistentID?
    var soundName: String = "none"
    var vibrateId: Int?
    var vibrateName: String = "none"
    var repeatWeekdays: [Week]
    var snoozeId: Int?

    func getLabel() -> String {
        if let theGroupId = groupId {
            let groupLabel = Groups.instance().group(byId: theGroupId).groupLabel
            return "\(groupLabel):\(alarmLabel)"
        } else {
            return alarmLabel
        }
    }

    func getRepeatWeekdays() -> [Week] {
        if let theGroupId = groupId {
            return Groups.instance().group(byId: theGroupId).repeatWeekdays
        } else {
            return repeatWeekdays
        }
    }

    func isRepeat() -> Bool {
        return !getRepeatWeekdays().isEmpty
    }

    // if the alarm belongs to one group, then the group must enabled too.
    func isEnabled() -> Bool {
        if let _ = groupId {
            return isGroupEnabled() && enabled
        } else {
            return enabled
        }
    }

    func isDisabled() -> Bool {
        return !isEnabled()
    }

    func isGroupEnabled() -> Bool {
        if let theGroupId = groupId {
            return Groups.instance().group(byId: theGroupId).enabled
        }
        return false
    }

    func isGroupDiabled() -> Bool {
        return !isGroupEnabled()
    }

    func isNonGroupAlarm() -> Bool {
        return groupId == nil
    }

    func isGroupAlarm() -> Bool {
        return !isNonGroupAlarm()
    }

    func setUpNotification() {
        if self.isEnabled() {
            Scheduler.setUpAlarmNotifications(self)
        } else {
            Scheduler.tearDownAlarmNotifications(self)
        }
    }

    func tearDownNotification() {
        Scheduler.tearDownAlarmNotifications(self)
    }
}

class Alarms {
    private static var instance_: Alarms? = nil
    private let persistNextAlarmIdKey = "NextAlarmIdKey"
    private let persistKey = "AlarmKey"
    private let userDefaults = UserDefaults.standard
    private var _alarms: Array<Alarm> = [] {
        didSet {
            persist()
        }
    }

    private init() {
        importNextAlarmId()
        importAlarms()
    }

    static func instance() -> Alarms {
        if instance_ == nil {
            instance_ = Alarms()
        }
        return instance_!
    }

    func alarm(byId id: Int) -> Alarm {
        for alarm in _alarms {
            if alarm.alarmId == id {
                return alarm
            }
        }
        fatalError()
    }

    func containsAlarm(byId id: Int) -> Bool {
        for alarm in _alarms {
            if alarm.alarmId == id {
                return true
            }
        }
        return false
    }

    func alarms() -> [Alarm] {
        return sorted(_alarms)
    }

    func alarms(byGroupId id: Int) -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.groupId == id {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func nonGroupAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.groupId == nil {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func groupAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.groupId != nil {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func enabledAlarms() -> [Alarm] {
        return sorted(enabledNonGroupAlarms() + enabledGroupAlarms())
    }

    func enabledNonGroupAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in nonGroupAlarms() {
            if alarm.isEnabled() {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func enabledGroupAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in groupAlarms() {
            if alarm.isEnabled() {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func enabledGroupAlarms(byGroupId id: Int) -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in enabledGroupAlarms() {
            if alarm.groupId == id {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func disabledAlarms() -> [Alarm] {
        return sorted(disabledNonGroupAlarms() + disabledGroupAlarms())
    }

    func disabledNonGroupAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in nonGroupAlarms() {
            if alarm.isDisabled() {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func disabledGroupAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in groupAlarms() {
            if alarm.isDisabled() {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func disabledGroupAlarms(byGroupId id: Int) -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in disabledGroupAlarms() {
            if alarm.groupId == id {
                alarms.append(alarm)
            }
        }
        return sorted(alarms)
    }

    func add(_ newAlarm: Alarm) {
        guard NextAlarmId < Int.max || reorganize() else {
            return
        }
        
        var alarm = newAlarm
        NextAlarmId += 1
        alarm.date = Utility.unifyDate(alarm.date)

        _alarms.append(alarm)
        alarm.setUpNotification()
    }

    func update(_ editedAlarm: Alarm) {
        remove(editedAlarm)
        add(editedAlarm)
    }

    func remove(_ deleteAlarm: Alarm) {
        deleteAlarm.tearDownNotification()
        for (index, alarm) in _alarms.enumerated() {
            if alarm.alarmId == deleteAlarm.alarmId {
                _alarms.remove(at: index)
                break
            }
        }
    }

    func removeAll() {
        _alarms.removeAll()
        persist()
    }

    fileprivate func reorganize() -> Bool {
        guard _alarms.count < Int.max else {
            return false
        }

        // tear down notifications
        for alarm in self._alarms {
            Scheduler.tearDownAlarmNotifications(alarm)
        }

        // remove all then add it again
        NextAlarmId = 0
        let alarms = self._alarms
        self._alarms.removeAll()
        for var alarm in alarms {
            alarm.alarmId = NextAlarmId
            self.add(alarm)
        }
        return true
    }

    private func persist() {
        userDefaults.set(NextAlarmId, forKey: persistNextAlarmIdKey)
        userDefaults.set(try? PropertyListEncoder().encode(_alarms), forKey: persistKey)
        userDefaults.synchronize()
    }

    private func unpersist() {
        userDefaults.removeObject(forKey: persistKey)
        userDefaults.removeObject(forKey: persistNextAlarmIdKey)
        userDefaults.synchronize()
    }

    private func importAlarms() {
        guard let data = userDefaults.value(forKey: persistKey) as? Data,
            let alarms = try? PropertyListDecoder().decode(Array<Alarm>.self, from: data)
            else {
                self._alarms = [Alarm]()
                return
        }
        self._alarms = alarms
    }

    private func importNextAlarmId() {
        guard let data = userDefaults.value(forKey: persistNextAlarmIdKey) as? Int else {
            NextAlarmId = 0
            return
        }
        NextAlarmId = data
    }

    fileprivate func sorted(_ alarms: [Alarm]) -> [Alarm] {
        return Utility.sortAlarmByTime(alarms.stableSorted(by: { (a, b) -> Bool in
            return a.alarmId < b.alarmId
        }))
    }
}

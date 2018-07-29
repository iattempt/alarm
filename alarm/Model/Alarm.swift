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

    func getRepeats() -> [Week] {
        if let groupId = GroupIdProp {
            return Groups.instance().group(byId: groupId).repeatWeekdays
        } else {
            return repeatWeekdays
        }
    }

    // if the alarm belongs to one group, then the group must enabled too.
    func isEnabled() -> Bool {
        if let _ = groupId {
            return isGroupEnabled() && enabled
        } else {
            return enabled
        }
    }

    func isGroupEnabled() -> Bool {
        if let theGroupId = groupId {
            if Groups.instance().group(byId: theGroupId).enabled {
                return true
            }
        }
        return false
    }

    func isDisabled() -> Bool {
        return !isEnabled()
    }

    func isDisperseAlarm() -> Bool {
        return groupId == nil
    }

    func isGroupAlarm() -> Bool {
        return !isDisperseAlarm()
    }

    func updateNotification() {
        if self.isEnabled() {
        } else {
        }
    }
}

class Alarms {
    private init() {
        importNextAlarmId()
        importDisperseAlarms()
    }
    private static var instance_: Alarms? = nil
    static func instance() -> Alarms {
        if instance_ == nil {
            instance_ = Alarms()
        }
        return instance_!
    }

    private let persistNextAlarmIdKey = "NextAlarmIdKey"
    private let persistKey = "AlarmKey"
    private let userDefaults = UserDefaults.standard
    private var _alarms: Array<Alarm> = [] {
        didSet {
            persist()
        }
    }

    func alarm(byId id: Int) -> Alarm {
        for alarm in _alarms {
            if alarm.alarmId == id {
                return alarm
            }
        }
        fatalError()
    }

    func alarms() -> [Alarm] {
        return Utility.sortAlarmByTime(_alarms.stableSorted(by: { (a, b) -> Bool in
            return a.alarmId < b.alarmId
        }))
    }

    func alarms(byGroupId id: Int) -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.groupId == id {
                alarms.append(alarm)
            }
        }
        return Utility.sortAlarmByTime(alarms.stableSorted(by: { (a, b) -> Bool in
            return a.alarmId < b.alarmId
        }))
    }

    func enabledAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.isEnabled() {
                alarms.append(alarm)
            }
        }
        return alarms
    }

    func disabledAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.isDisabled() {
                alarms.append(alarm)
            }
        }
        return alarms
    }

    func enabledDisperseAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.isDisperseAlarm() && alarm.isEnabled() {
                alarms.append(alarm)
            }
        }
        return alarms
    }

    func disabledDisperseAlarms() -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.isDisperseAlarm() && alarm.isDisabled() {
                alarms.append(alarm)
            }
        }
        return alarms
    }

    func enabledGroupAlarms(byGroupId id: Int) -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.isGroupAlarm() && alarm.isEnabled() {
                alarms.append(alarm)
            }
        }
        return alarms
    }

    func disabledGroupAlarms(byGroupId id: Int) -> [Alarm] {
        var alarms = [Alarm]()
        for alarm in _alarms {
            if alarm.isGroupAlarm() && alarm.isDisabled() {
                alarms.append(alarm)
            }
        }
        return alarms
    }

    func nonGroupAlarms() -> [Alarm] {
        var nonGroupAlarms = [Alarm]()
        for alarm in _alarms {
            if alarm.groupId == nil {
                nonGroupAlarms.append(alarm)
            }
        }
        return Utility.sortAlarmByTime(nonGroupAlarms.stableSorted(by: { (a, b) -> Bool in
            return a.alarmId < b.alarmId
        }))
    }

    func groupAlarms() -> [Alarm] {
        var groupAlarms = [Alarm]()
        for alarm in _alarms {
            if alarm.groupId != nil {
                groupAlarms.append(alarm)
            }
        }
        return Utility.sortAlarmByTime(groupAlarms.stableSorted(by: { (a, b) -> Bool in
            return a.alarmId < b.alarmId
        }))
    }

    func addAlarm(_ newAlarm: Alarm) {
        guard NextAlarmId < Int.max || reorganize() else {
            return
        }
        
        var alarm = newAlarm
        NextAlarmId += 1
        alarm.date = Utility.unifyDate(alarm.date)

        _alarms.append(alarm)
        alarm.updateNotification()
    }

    func updateAlarm(_ editedAlarm: Alarm) {
        var alarm = editedAlarm
        alarm.date = Utility.unifyDate(alarm.date)
        let index = Utility.binarySearch(_alarms,
                                         key: alarm.alarmId,
                                         range: 0..<_alarms.count)
        guard let i = index,
            _alarms[i].alarmId == alarm.alarmId else {
            fatalError("the id:\(alarm.alarmId) is not found.")
        }
        _alarms[i] = alarm
        alarm.updateNotification()
    }

    func deleteAlarm(_ deleteAlarm: Alarm) {
        deleteAlarm.updateNotification()
        for (index, alarm) in _alarms.enumerated() {
            if alarm.alarmId == deleteAlarm.alarmId {
                _alarms.remove(at: index)
                break
            }
        }
    }

    func emptyAlarm() {
        NextAlarmId = 0
        _alarms.removeAll()
        persist()
    }

    fileprivate func reorganize() -> Bool{
        guard _alarms.count < Int.max else {
            return false
        }

        // tear down notifications
        for alarm in self._alarms {
            alarm.updateNotification()
        }

        // remove all then add it again
        let alarms = self._alarms
        NextAlarmId = 0
        for var alarm in alarms {
            alarm.alarmId = NextAlarmId
            self.addAlarm(alarm)
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
        userDefaults.synchronize()
    }

    private func importDisperseAlarms() {
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
}

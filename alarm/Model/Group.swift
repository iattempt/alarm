//
//  Group.swift
//  alarm
//
//  Created by Ernest on 03/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation

var NextGroupId: Int = 0

struct Group: Codable {
    var groupId: Int = 0
    var groupLabel = ""
    var enabled = false
    var repeatWeekdays: [Week] = [Week]()

    func updateNotification() {
        let alarms = Alarms.instance().alarms(byGroupId: groupId)
        for alarm in alarms {
            alarm.updateNotification()
        }
    }
}

class Groups {
    private init() {
        importNextAlarmId()
        importDisperseAlarms()
    }
    private static var instance_: Groups? = nil
    static func instance() -> Groups {
        if instance_ == nil {
            instance_ = Groups()
        }
        return instance_!
    }

    private let persistNextGroupIdKey = "NextGroupIdKey"
    private let persistKey = "GroupKey"
    private let userDefaults = UserDefaults.standard
    private var _groups: Array<Group> = [] {
        didSet {
            persist()
        }
    }

    func groups() -> [Group] {
        return _groups.stableSorted(by: { (a, b) -> Bool in
            return a.groupId < b.groupId
        })
    }

    func group(byId id: Int) -> Group {
        for group in _groups {
            if group.groupId == id {
                return group
            }
        }
        fatalError()
    }

    func addGroup(_ group: Group) {
        guard NextGroupId < Int.max || reorganize() else {
            return
        }

        NextGroupId += 1
        _groups.append(group)
    }

    func updateGroup(_ editedGroup: Group) {
        for (index, group) in _groups.enumerated() {
            if group.groupId == editedGroup.groupId {
                _groups[index] = editedGroup
                break
            }
        }
        editedGroup.updateNotification()
    }

    func deleteGroup(_ deleteGroup: Group) {
        for (index, group) in _groups.enumerated() {
            if group.groupId == deleteGroup.groupId {
                _groups.remove(at: index)
                break
            }
        }
        deleteGroup.updateNotification()
    }

    func emptyGroup() {
        _groups.removeAll()
        NextGroupId = 0
        persist()
    }

    fileprivate func reorganize() -> Bool {
        guard _groups.count < Int.max else {
            return false
        }

        // tear down notifications
        for var group in _groups {
            group.enabled = false
            group.updateNotification()
            for alarm in Alarms.instance().alarms(byGroupId: group.groupId) {
                alarm.updateNotification()
            }
        }

        // remove all then add it again
        NextGroupId = 0
        let groups = self._groups
        self._groups.removeAll()
        for var group in groups {
            group.groupId = NextGroupId
            self.addGroup(group)
            // update groupId for alarms which belong to current group
            for var alarm in Alarms.instance().alarms(byGroupId: group.groupId) {
                alarm.groupId = NextGroupId
                Alarms.instance().updateAlarm(alarm)
            }
        }
        return true
    }

    private func persist() {
        userDefaults.set(NextAlarmId, forKey: persistNextGroupIdKey)
        userDefaults.set(try? PropertyListEncoder().encode(_groups), forKey: persistKey)
        userDefaults.synchronize()
    }

    private func unpersist() {
        userDefaults.removeObject(forKey: persistKey)
        userDefaults.synchronize()
    }

    private func importDisperseAlarms() {
        guard let data = userDefaults.value(forKey: persistKey) as? Data,
            let groups = try? PropertyListDecoder().decode(Array<Group>.self, from: data)
            else {
                self._groups = [Group]()
                return
        }
        self._groups = groups
    }

    private func importNextAlarmId() {
        guard let data = userDefaults.value(forKey: persistNextGroupIdKey) as? Int else {
            NextGroupId = 0
            return
        }
        NextGroupId = data
    }
}


//
//  Group.swift
//  alarm
//
//  Created by Ernest on 03/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation

var nextGroupId: Int = 0

struct Group: Codable {
    var groupId: Int = 0
    var groupLabel = ""
    var enabled = false
    var repeatWeekdays: [String: Bool] = [String: Bool]()
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
        assert(false)
        return Group()
    }

    func addGroup(_ group: Group) {
        nextGroupId += 1
        _groups.append(group)
    }

    func updateGroup(_ editedGroup: Group) {
        for (index, group) in _groups.enumerated() {
            if group.groupId == editedGroup.groupId {
                _groups[index] = editedGroup
                break
            }
        }
    }

    func deleteGroup(_ deleteGroup: Group) {
        for (index, group) in _groups.enumerated() {
            if group.groupId == deleteGroup.groupId {
                _groups.remove(at: index)
                break
            }
        }
    }

    func emptyGroup() {
        nextGroupId = 0
        _groups.removeAll()
        persist()
    }

    private func persist() {
        userDefaults.set(nextAlarmId, forKey: persistNextGroupIdKey)
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
            nextGroupId = 0
            return
        }
        nextGroupId = data
    }
}


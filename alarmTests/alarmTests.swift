//
//  alarmTests.swift
//  alarmTests
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation
import XCTest
@testable import alarm

class alarmTests: XCTestCase {
    let callingFunctionMaxTimes = 3
    let callingFunctionMaxTimesForMixOperation = 15
    let interactFunctionCounts = 7
    var currentTestedFunctions: [String: Int] = [String: Int]()

    override func setUp() {
        super.setUp()
        currentTestedFunctions.removeAll()

        Alarms.instance().removeAll()
        Groups.instance().removeAll()

        NextAlarmId = 0
        NextGroupId = 0

        SelectedAlarm = nil
        SelectedGroup = nil

        IsLoadedPropertiesOfSelectedAlarmOrGroup = false
        AlarmIdProp = 0
        LabelProp = ""
        EnabledProp = true
        SoundIdProp = nil
        VibrateIdProp = nil
        SnoozeIdProp = 9
        GroupIdProp = nil
        RepeatWeeksProp = [Week]()
    }
    
    override func tearDown() {
        super.tearDown()
        Alarms.instance().removeAll()
        Groups.instance().removeAll()
        UserDefaults.standard.set(false, forKey: "firstLaunched")
    }

    func interactCalling() throws {
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testAddAlarmWithUserDefined()") ||
                currentTestedFunctions["_testAddAlarmWithUserDefined()"]! < callingFunctionMaxTimes) {
            try _testAddAlarmWithUserDefined()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testAddAlarmWithoutUserDefined()") ||
                currentTestedFunctions["_testAddAlarmWithoutUserDefined()"]! < callingFunctionMaxTimes) {
            try _testAddAlarmWithoutUserDefined()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testUpdateAlarm()") ||
                currentTestedFunctions["_testUpdateAlarm()"]! < callingFunctionMaxTimes) {
            try _testUpdateAlarm()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testAddGroupWithUserDefined()") ||
                currentTestedFunctions["_testAddGroupWithUserDefined()"]! < callingFunctionMaxTimes) {
            try _testAddGroupWithUserDefined()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testAddGroupWithoutUserDefined()") ||
                currentTestedFunctions["_testAddGroupWithoutUserDefined()"]! < callingFunctionMaxTimes) {
            try _testAddGroupWithoutUserDefined()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testUpdateGroup()") ||
                currentTestedFunctions["_testUpdateGroup()"]! < callingFunctionMaxTimes) {
            try _testUpdateGroup()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testMoveAlarmInOutGroup()") ||
                currentTestedFunctions["_testMoveAlarmInOutGroup()"]! < callingFunctionMaxTimes) {
            try _testMoveAlarmInOutGroup()
        }
    }

    func interactCallingForMixOperation() throws {
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testAddAlarm()") ||
                currentTestedFunctions["_testAddAlarm()"]! < callingFunctionMaxTimesForMixOperation) {
            try _testAddAlarm()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testDeleteAlarm()") ||
                currentTestedFunctions["_testDeleteAlarm()"]! < callingFunctionMaxTimesForMixOperation) {
            try _testDeleteAlarm()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testAddGroup()") ||
                currentTestedFunctions["_testAddGroup()"]! < callingFunctionMaxTimesForMixOperation) {
            try _testAddGroup()
        }
        if Utility.randomInt() % interactFunctionCounts == 0 &&
            (!currentTestedFunctions.keys.contains("_testDeleteGroup()") ||
                currentTestedFunctions["_testDeleteGroup()"]! < callingFunctionMaxTimesForMixOperation) {
            try _testDeleteGroup()
        }
    }

    func testMultipleRoundsForInteractForUI() throws {
        for firstCallingFunction in 0...interactFunctionCounts * 3 {
            // print("\nRound:\(firstCallingFunction)\n ", terminator: "")
            setUp()

            switch (firstCallingFunction % interactFunctionCounts) {
            case 0:
                try _testAddAlarmWithoutUserDefined()
            case 1:
                try _testAddAlarmWithUserDefined()
            case 2:
                try _testUpdateAlarm()
            case 3:
                try _testAddGroupWithoutUserDefined()
            case 4:
                try _testAddGroupWithUserDefined()
            case 5:
                try _testUpdateGroup()
            case 6:
                try _testMoveAlarmInOutGroup()
            default:
                break
            }
        }
        // print()
    }

    func _testAddAlarmWithoutUserDefined() throws {
        // print(1, terminator: "")
        incrementCallingFuncionTimes(#function)

        let controller = ModifyAlarmViewController()
        let dp: UIDatePicker = UIDatePicker()
        controller.datePicker = dp
        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            SelectedAlarm = nil
            SelectedGroup = nil
            controller.datePicker.date = Date().addMinutes(Int(arc4random() % 1440))
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given

            // when
            controller.addAlarm()

            // then
            let alarm = Alarms.instance().alarm(byId: NextAlarmId - 1)

            XCTAssert(alarm.alarmId == NextAlarmId - 1)
            XCTAssert(alarm.groupId == nil)
            XCTAssert(alarm.alarmLabel == LabelProp)
            XCTAssert(alarm.enabled == EnabledProp)
            XCTAssert(alarm.date == Utility.unifyDate(controller.datePicker.date))
            XCTAssert(alarm.soundId == SoundIdProp)
            XCTAssert(alarm.vibrateId == VibrateIdProp)
            XCTAssert(alarm.repeatWeeks.count == RepeatWeeksProp.count)
            XCTAssert(alarm.repeatWeeks == RepeatWeeksProp)
            XCTAssert(alarm.snoozeId == SnoozeIdProp)
        }
    }

    func _testAddAlarmWithUserDefined() throws {
        // print(2, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyAlarmViewController()
        let dp: UIDatePicker = UIDatePicker()
        controller.datePicker = dp
        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            controller.datePicker.date = Date().addMinutes(Utility.randomInt(1440))
            LabelProp = Utility.randomAlphaNumber(length: 5)
            SoundIdProp = nil
            VibrateIdProp = Utility.randomInt()
            SnoozeIdProp = Utility.randomInt()
            GroupIdProp = nil
            RepeatWeeksProp = getRandomRepeatWeekdays()

            SelectedAlarm = nil
            SelectedGroup = nil
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given

            // when
            controller.addAlarm()

            // then
            let alarm = Alarms.instance().alarm(byId: NextAlarmId - 1)

            XCTAssert(alarm.alarmId == NextAlarmId - 1)
            XCTAssert(alarm.groupId == nil)
            XCTAssert(alarm.alarmLabel == LabelProp)
            XCTAssert(alarm.enabled == EnabledProp)
            XCTAssert(alarm.date == Utility.unifyDate(controller.datePicker.date))
            XCTAssert(alarm.soundId == SoundIdProp)
            XCTAssert(alarm.vibrateId == VibrateIdProp)
            XCTAssert(alarm.repeatWeeks.count == RepeatWeeksProp.count)
            XCTAssert(alarm.repeatWeeks == RepeatWeeksProp)
            XCTAssert(alarm.snoozeId == SnoozeIdProp)
        }
    }

    func _testUpdateAlarm() throws {
        // print(3, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyAlarmViewController()
        let dp: UIDatePicker = UIDatePicker()
        controller.datePicker = dp

        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()
            if Alarms.instance().alarms().isEmpty {
                continue
            }

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            SelectedAlarm = Alarms.instance().alarm(byId: 0)
            SelectedGroup = nil
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given
            controller.datePicker.date = Date().addMinutes(Utility.randomInt(1440))
            GroupIdProp = nil
            LabelProp = Utility.randomAlphaNumber(length: 5)
            SoundIdProp = nil
            VibrateIdProp = Utility.randomInt()
            SnoozeIdProp = Utility.randomInt()
            RepeatWeeksProp = getRandomRepeatWeekdays()

            // when
            controller.updateAlarm(SelectedAlarm!)

            // then
            let alarm = Alarms.instance().alarm(byId: 0)

            XCTAssert(alarm.alarmId == 0)
            XCTAssert(alarm.groupId == nil)
            XCTAssert(alarm.alarmLabel == LabelProp)
            XCTAssert(alarm.enabled == EnabledProp)
            XCTAssert(alarm.date == Utility.unifyDate(controller.datePicker.date))
            XCTAssert(alarm.soundId == SoundIdProp)
            XCTAssert(alarm.vibrateId == VibrateIdProp)
            XCTAssert(alarm.repeatWeeks.count == RepeatWeeksProp.count)
            XCTAssert(alarm.repeatWeeks == RepeatWeeksProp)
            XCTAssert(alarm.snoozeId == SnoozeIdProp)
        }
    }

    func _testAddGroupWithoutUserDefined() throws {
        // print(4, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyGroupViewController()
        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            SelectedAlarm = nil
            SelectedGroup = nil
            controller.loadProperties(group: SelectedGroup)

            // given

            // when
            controller.addGroup()

            // then
            let group = Groups.instance().group(byId: NextGroupId - 1)

            XCTAssert(group.groupId == NextGroupId - 1)
            XCTAssert(group.groupLabel == LabelProp)
            XCTAssert(group.repeatWeeks.count == RepeatWeeksProp.count)
            XCTAssert(group.repeatWeeks == RepeatWeeksProp)
        }
    }

    func _testAddGroupWithUserDefined() throws {
        // print(5, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyGroupViewController()
        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            LabelProp = Utility.randomAlphaNumber(length: 5)
            RepeatWeeksProp = getRandomRepeatWeekdays()
            SelectedAlarm = nil
            SelectedGroup = nil
            controller.loadProperties(group: SelectedGroup)

            // given

            // when
            controller.addGroup()

            // then
            let group = Groups.instance().group(byId: NextGroupId - 1)

            XCTAssert(group.groupId == NextGroupId - 1)
            XCTAssert(group.groupLabel == LabelProp)
            XCTAssert(group.repeatWeeks.count == RepeatWeeksProp.count)
            XCTAssert(group.repeatWeeks == RepeatWeeksProp)
        }
    }

    func _testUpdateGroup() throws {
        // print(6, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyGroupViewController()

        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()
            if Groups.instance().groups().isEmpty {
                continue
            }

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            SelectedAlarm = nil
            SelectedGroup = Groups.instance().group(byId: 0)
            controller.loadProperties(group: SelectedGroup)

            // given
            LabelProp = Utility.randomAlphaNumber(length: 5)
            RepeatWeeksProp = getRandomRepeatWeekdays()
            // when
            controller.updateGroup(SelectedGroup!)

            // then
            let group = Groups.instance().group(byId: 0)

            XCTAssert(group.groupId == 0)
            XCTAssert(group.groupLabel == LabelProp)
            XCTAssert(group.repeatWeeks.count == RepeatWeeksProp.count)
            XCTAssert(group.repeatWeeks == RepeatWeeksProp)
        }
    }

    func _testMoveAlarmInOutGroup() throws {
        // print(7, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyAlarmViewController()
        let dp: UIDatePicker = UIDatePicker()
        controller.datePicker = dp

        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()
            if Alarms.instance().alarms().isEmpty || Groups.instance().groups().isEmpty {
                continue
            }

            // set up
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            SelectedAlarm = Alarms.instance().alarms()[0]
            if let id = SelectedAlarm?.groupId {
                SelectedGroup = Groups.instance().group(byId: id)
            } else {
                SelectedGroup = nil
            }
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given
            GroupIdProp = SelectedGroup == nil ? 0 : nil

            // when
            controller.updateAlarm(SelectedAlarm!)

            // then
            let alarm = Alarms.instance().alarm(byId: (SelectedAlarm?.alarmId)!)

            XCTAssert(alarm.groupId == GroupIdProp)
        }
    }
}

extension alarmTests {
    func testMixOperation() throws {
        for r in 0...10 {
            switch (r % 4) {
            case 0:
                try _testAddAlarm()
            case 1:
                try _testDeleteAlarm()
            case 2:
                try _testAddGroup()
            case 3:
                try _testDeleteGroup()
            default:
                break
            }
        }
    }

    func _testAddAlarm() throws {
        incrementCallingFuncionTimes(#function)
        for _ in 0...30 {
            try interactCallingForMixOperation()

            // given
            let id = NextAlarmId
            let alarm = Alarm(alarmId: id, alarmLabel: "", groupId: nil, enabled: false, date: Date(), soundId: nil, soundName: "", vibrateId: nil, vibrateName: "", repeatWeekdays: [], snoozeId: nil)

            // when
            Alarms.instance().add(alarm)

            // then
            XCTAssertTrue(Alarms.instance().containsAlarm(byId: id))
        }
    }

    func _testDeleteAlarm() throws {
        incrementCallingFuncionTimes(#function)
        for c in 0...30 {
            if c % 5 == 0 {
                try interactCallingForMixOperation()
            }
            guard Alarms.instance().alarms().count > 0 else {
                return
            }

            // given
            let alarms = Alarms.instance().alarms()
            var deleteAlarm = alarms[0]
            for alarm in alarms {
                if Utility.randomBool() {
                    deleteAlarm = alarm
                }
            }

            // when
            Alarms.instance().remove(deleteAlarm)

            // then
            XCTAssertFalse(Alarms.instance().containsAlarm(byId: deleteAlarm.alarmId))
        }
    }

    func _testAddGroup() throws {
        incrementCallingFuncionTimes(#function)
        for _ in 0...30 {
            try interactCallingForMixOperation()

            // given
            let id = NextGroupId
            let group = Group(groupId: id, groupLabel: "", enabled: false, repeatWeekdays: [])

            // when
            Groups.instance().add(group)

            // then
            XCTAssertTrue(Groups.instance().containsGroup(byId: id))
        }
    }

    func _testDeleteGroup() throws {
        incrementCallingFuncionTimes(#function)
        for c in 0...30 {
            if c % 5 == 0 {
                try interactCallingForMixOperation()
            }
            guard Groups.instance().groups().count > 0 else {
                return
            }

            // given
            let groups = Groups.instance().groups()
            var deleteGroup = groups[0]
            for group in groups {
                if Utility.randomBool() {
                    deleteGroup = group
                }
            }

            // when
            Groups.instance().remove(deleteGroup)

            // then
            XCTAssertFalse(Groups.instance().containsGroup(byId: deleteGroup.groupId))
        }
    }
}

// performance
extension alarmTests {
    func testAddAlarmPerformance() throws {
        let controller = ModifyAlarmViewController()
        let dp: UIDatePicker = UIDatePicker()
        controller.datePicker = dp
        controller.datePicker.date = Date().addMinutes(Int(arc4random() % 1440))
        SelectedAlarm = nil
        SelectedGroup = nil

        for _ in 0...200 {
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)
            controller.addAlarm()
        }
    }

    func testUpdateAlarmPerformance() throws {
        try testAddAlarmPerformance()

        let controller = ModifyAlarmViewController()
        let dp: UIDatePicker = UIDatePicker()
        controller.datePicker = dp
        controller.datePicker.date = Date().addMinutes(Utility.randomInt(1440))
        GroupIdProp = nil
        LabelProp = Utility.randomAlphaNumber(length: 5)
        SoundIdProp = nil
        VibrateIdProp = Utility.randomInt()
        SnoozeIdProp = Utility.randomInt()
        RepeatWeeksProp = getRandomRepeatWeekdays()

        for i in 0...200 {
            SelectedAlarm = Alarms.instance().alarm(byId: i)
            SelectedGroup = nil
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)
            controller.updateAlarm(SelectedAlarm!)
        }
    }

    func testAddGroupPerformance() throws {
        let controller = ModifyGroupViewController()

        SelectedAlarm = nil
        SelectedGroup = nil

        for _ in 0...200 {
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            controller.loadProperties(group: SelectedGroup)
            controller.addGroup()
        }
    }

    func testUpdateGroupPerformance() throws {
        try testAddGroupPerformance()

        let controller = ModifyGroupViewController()

        for i in 0...200 {
            IsLoadedPropertiesOfSelectedAlarmOrGroup = false
            SelectedAlarm = nil
            SelectedGroup = Groups.instance().group(byId: i)
            controller.loadProperties(group: SelectedGroup)
            // when
            controller.updateGroup(SelectedGroup!)
        }
    }
}

extension alarmTests {
    func testPredicate() {
        let alarm1 = Alarm(alarmId: 0, alarmLabel: "", groupId: nil, enabled: false, date: Date(), soundId: nil, soundName: "", vibrateId: nil, vibrateName: "", repeatWeekdays: [], snoozeId: nil)

        XCTAssertTrue(alarm1.isNonGroupAlarm())
        XCTAssertTrue(alarm1.isDisabled())

        XCTAssertFalse(alarm1.isGroupAlarm())
        XCTAssertFalse(alarm1.isEnabled())
        XCTAssertFalse(alarm1.isRepeat())

        let alarm2 = Alarm(alarmId: 0, alarmLabel: "", groupId: 0, enabled: true, date: Date(), soundId: nil, soundName: "", vibrateId: nil, vibrateName: "", repeatWeekdays: [], snoozeId: nil)
        let group2 = Group(groupId: 0, groupLabel: "", enabled: true, repeatWeekdays: Week.allCases)
        Groups.instance().add(group2)

        XCTAssertTrue(alarm2.isGroupAlarm())
        XCTAssertTrue(alarm2.isEnabled())
        XCTAssertTrue(alarm2.isRepeat())
        XCTAssertTrue(alarm2.isGroupEnabled())

        XCTAssertFalse(alarm2.isGroupDiabled())
        XCTAssertFalse(alarm2.isNonGroupAlarm())
        XCTAssertFalse(alarm2.isDisabled())
    }
}

extension alarmTests {
    fileprivate func incrementCallingFuncionTimes(_ name: String) {
        if currentTestedFunctions.keys.contains(name) {
            currentTestedFunctions[name] = currentTestedFunctions[name]! + 1
        } else {
            currentTestedFunctions[name] = 1
        }
    }

    fileprivate func getRandomRepeatWeekdays() -> [Week] {
        var weeks = [Week]()
        for week in Week.allCases {
            if Utility.randomBool() {
                weeks.append(week)
            }
        }
        return weeks
    }
}

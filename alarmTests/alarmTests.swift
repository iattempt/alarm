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
    let interactFunctionCounts = 7
    var currentTestedFunctions: [String: Int] = [String: Int]()

    override func setUp() {
        super.setUp()
        currentTestedFunctions.removeAll()

        Alarms.instance().emptyAlarm()
        Groups.instance().emptyGroup()

        nextAlarmId = 0
        nextGroupId = 0

        SelectedAlarm = nil
        SelectedGroup = nil

        doesUpdateAlarm = false
        isGroup = false
        doesUpdateGroup = false

        isInitialized = false
        AlarmIdProp = 0
        LabelProp = ""
        EnabledProp = true
        SoundIdProp = nil
        VibrateIdProp = nil
        SnoozeIdProp = 9
        GroupIdProp = nil
        RepeatWeekdaysProp = [String: Bool]()
    }
    
    override func tearDown() {
        super.tearDown()
        Alarms.instance().emptyAlarm()
        Groups.instance().emptyGroup()
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

    func testMultipleRoundsForInteract() throws {
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
            isInitialized = false
            SelectedAlarm = nil
            SelectedGroup = nil
            controller.datePicker.date = Date().addMinutes(Int(arc4random() % 1440))
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given

            // when
            controller.addAlarm()

            // then
            let alarm = Alarms.instance().alarm(byId: nextAlarmId - 1)

            XCTAssert(Alarms.instance().alarms().count == nextAlarmId)
            XCTAssert(Groups.instance().groups().count == nextGroupId)

            XCTAssert(alarm.alarmId == nextAlarmId - 1)
            XCTAssert(alarm.groupId == nil)
            XCTAssert(alarm.alarmLabel == LabelProp)
            XCTAssert(alarm.enabled == EnabledProp)
            XCTAssert(alarm.date == Utility.unifyDate(controller.datePicker.date))
            XCTAssert(alarm.soundId == SoundIdProp)
            XCTAssert(alarm.vibrateId == VibrateIdProp)
            XCTAssert(alarm.repeatWeekdays.count == RepeatWeekdaysProp.count)
            XCTAssert(alarm.repeatWeekdays == RepeatWeekdaysProp)
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
            isInitialized = false
            controller.datePicker.date = Date().addMinutes(Utility.randomInt(1440))
            LabelProp = Utility.randomString(length: 5)
            SoundIdProp = Utility.randomInt()
            VibrateIdProp = Utility.randomInt()
            SnoozeIdProp = Utility.randomInt()
            GroupIdProp = nil
            RepeatWeekdaysProp = getRandomRepeatWeekdays()

            SelectedAlarm = nil
            SelectedGroup = nil
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given

            // when
            controller.addAlarm()

            // then
            let alarm = Alarms.instance().alarm(byId: nextAlarmId - 1)

            XCTAssert(Alarms.instance().alarms().count == nextAlarmId)
            XCTAssert(Groups.instance().groups().count == nextGroupId)

            XCTAssert(alarm.alarmId == nextAlarmId - 1)
            XCTAssert(alarm.groupId == nil)
            XCTAssert(alarm.alarmLabel == LabelProp)
            XCTAssert(alarm.enabled == EnabledProp)
            XCTAssert(alarm.date == Utility.unifyDate(controller.datePicker.date))
            XCTAssert(alarm.soundId == SoundIdProp)
            XCTAssert(alarm.vibrateId == VibrateIdProp)
            XCTAssert(alarm.repeatWeekdays.count == RepeatWeekdaysProp.count)
            XCTAssert(alarm.repeatWeekdays == RepeatWeekdaysProp)
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
            isInitialized = false
            SelectedAlarm = Alarms.instance().alarm(byId: 0)
            SelectedGroup = nil
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given
            controller.datePicker.date = Date().addMinutes(Utility.randomInt(1440))
            GroupIdProp = nil
            LabelProp = Utility.randomString(length: 5)
            SoundIdProp = Utility.randomInt()
            VibrateIdProp = Utility.randomInt()
            SnoozeIdProp = Utility.randomInt()
            RepeatWeekdaysProp = getRandomRepeatWeekdays()

            // when
            controller.updateAlarm()

            // then
            let alarm = Alarms.instance().alarm(byId: 0)

            XCTAssert(nextAlarmId == Alarms.instance().alarms().count)
            XCTAssert(nextGroupId == Groups.instance().groups().count)

            XCTAssert(alarm.alarmId == 0)
            XCTAssert(alarm.groupId == nil)
            XCTAssert(alarm.alarmLabel == LabelProp)
            XCTAssert(alarm.enabled == EnabledProp)
            XCTAssert(alarm.date == Utility.unifyDate(controller.datePicker.date))
            XCTAssert(alarm.soundId == SoundIdProp)
            XCTAssert(alarm.vibrateId == VibrateIdProp)
            XCTAssert(alarm.repeatWeekdays.count == RepeatWeekdaysProp.count)
            XCTAssert(alarm.repeatWeekdays == RepeatWeekdaysProp)
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
            isInitialized = false
            SelectedAlarm = nil
            SelectedGroup = nil
            controller.loadProperties(group: SelectedGroup)

            // given

            // when
            controller.addGroup()

            // then
            let group = Groups.instance().group(byId: nextGroupId - 1)

            XCTAssert(Groups.instance().groups().count == nextGroupId)
            XCTAssert(group.groupId == nextGroupId - 1)
            XCTAssert(group.groupLabel == LabelProp)
            XCTAssert(group.repeatWeekdays.count == RepeatWeekdaysProp.count)
            XCTAssert(group.repeatWeekdays == RepeatWeekdaysProp)
        }
    }

    func _testAddGroupWithUserDefined() throws {
        // print(5, terminator: "")
        incrementCallingFuncionTimes(#function)
        let controller = ModifyGroupViewController()
        for _ in 0...30 / interactFunctionCounts {
            try interactCalling()

            // set up
            isInitialized = false
            LabelProp = Utility.randomString(length: 5)
            RepeatWeekdaysProp = getRandomRepeatWeekdays()
            SelectedAlarm = nil
            SelectedGroup = nil
            controller.loadProperties(group: SelectedGroup)

            // given

            // when
            controller.addGroup()

            // then
            let group = Groups.instance().group(byId: nextGroupId - 1)

            XCTAssert(Groups.instance().groups().count == nextGroupId)

            XCTAssert(group.groupId == nextGroupId - 1)
            XCTAssert(group.groupLabel == LabelProp)
            XCTAssert(group.repeatWeekdays.count == RepeatWeekdaysProp.count)
            XCTAssert(group.repeatWeekdays == RepeatWeekdaysProp)
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
            isInitialized = false
            SelectedAlarm = nil
            SelectedGroup = Groups.instance().group(byId: 0)
            controller.loadProperties(group: SelectedGroup)

            // given
            LabelProp = Utility.randomString(length: 5)
            RepeatWeekdaysProp = getRandomRepeatWeekdays()
            // when
            controller.updateGroup()

            // then
            let group = Groups.instance().group(byId: 0)

            XCTAssert(nextGroupId == Groups.instance().groups().count)
            XCTAssert(group.groupId == 0)
            XCTAssert(group.groupLabel == LabelProp)
            XCTAssert(group.repeatWeekdays.count == RepeatWeekdaysProp.count)
            XCTAssert(group.repeatWeekdays == RepeatWeekdaysProp)
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
            isInitialized = false
            SelectedAlarm = Alarms.instance().alarm(
                byId: (Utility.randomInt(Alarms.instance().alarms().count)))
            if let id = SelectedAlarm?.groupId {
                SelectedGroup = Groups.instance().group(byId: id)
            } else {
                SelectedGroup = nil
            }
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)

            // given
            GroupIdProp = SelectedGroup == nil ? 0 : nil

            // when
            controller.updateAlarm()

            // then
            let alarm = Alarms.instance().alarm(byId: (SelectedAlarm?.alarmId)!)

            XCTAssert(nextAlarmId == Alarms.instance().alarms().count)
            XCTAssert(nextGroupId == Groups.instance().groups().count)

            XCTAssert(alarm.groupId == GroupIdProp)
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
            isInitialized = false
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
        LabelProp = Utility.randomString(length: 5)
        SoundIdProp = Utility.randomInt()
        VibrateIdProp = Utility.randomInt()
        SnoozeIdProp = Utility.randomInt()
        RepeatWeekdaysProp = getRandomRepeatWeekdays()

        for i in 0...200 {
            SelectedAlarm = Alarms.instance().alarm(byId: i)
            SelectedGroup = nil
            isInitialized = false
            controller.loadProperties(alarm: SelectedAlarm, group: SelectedGroup)
            controller.updateAlarm()
        }
    }

    func testAddGroupPerformance() throws {
        let controller = ModifyGroupViewController()

        SelectedAlarm = nil
        SelectedGroup = nil

        for _ in 0...200 {
            isInitialized = false
            controller.loadProperties(group: SelectedGroup)
            controller.addGroup()
        }
    }

    func testUpdateGroupPerformance() throws {
        try testAddGroupPerformance()

        let controller = ModifyGroupViewController()

        for i in 0...200 {
            isInitialized = false
            SelectedAlarm = nil
            SelectedGroup = Groups.instance().group(byId: i)
            controller.loadProperties(group: SelectedGroup)
            // when
            controller.updateGroup()
        }
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

    fileprivate func getRandomRepeatWeekdays() -> [String : Bool] {
        return ["Sunday": Utility.randomBool(),
                "Monday": Utility.randomBool(),
                "Tuesday": Utility.randomBool(),
                "Wednesday": Utility.randomBool(),
                "Thursday": Utility.randomBool(),
                "Friday": Utility.randomBool(),
                "Saturday": Utility.randomBool()]
    }
}

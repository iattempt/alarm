//
//  ViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import UserNotifications

// be used for adding/editing
var SelectedAlarm: Alarm? = nil
var SelectedGroup: Group? = nil

// only reload properties while create/select an alarm for editing
var IsLoadedProperties: Bool = false
// used to store properties while adding or editing alarm/group
var AlarmIdProp: Int = 0
var LabelProp: String = ""
var EnabledProp: Bool = true
var SoundIdProp: MPMediaEntityPersistentID?
var SoundNameProp = "none"
var VibrateIdProp: Int?
var VibrateNameProp = "none"
var SnoozeIdProp: Int?
var GroupIdProp: Int? = nil
var RepeatWeekdaysProp: [Week] = [Week]()


class EntryViewController: UITabBarController {
    override func viewDidLoad() {
        UIWindow.appearance().tintColor = UIColor.black
        super.viewDidLoad()
        requestAuthorize()
        addCategory()
    }

    override func viewWillAppear(_ animated: Bool) {
        initUtility()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func addCategory() {
        let snoozeAction = UNNotificationAction(identifier: "Snooze",
                                                title: "Snooze",
                                                options: [.destructive])
        let stopAction = UNNotificationAction(identifier: "Stop",
                                              title: "Stop",
                                              options: [])
        let snoozeCategory = UNNotificationCategory(identifier: "Snooze",
                                              actions: [snoozeAction, stopAction],
                                              intentIdentifiers: [],
                                              options: [])
        UNUserNotificationCenter.current().setNotificationCategories([snoozeCategory])
    }
}

extension EntryViewController {
    func initUtility() {
        let _ = Utility()
    }

    func requestAuthorize() {
        if !UserDefaults.standard.bool(forKey: "firstLaunched") {
            // used for me
            loadMyAlarms()

            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            requestMusicUsage()
            requestNotificationUsage()

            UserDefaults.standard.set(true, forKey: "firstLaunched")
        }
    }

    fileprivate func requestMusicUsage() {
        MPMediaQuery.songs()
    }

    fileprivate func requestNotificationUsage() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {(_,_) in}
    }

    func loadMyAlarms() {
        NextAlarmId = 0
        NextGroupId = 0
        Alarms.instance().emptyAlarm()
        Groups.instance().emptyGroup()

        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "起床",
                                         groupId: nil,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 6,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: 10))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "拿包裹",
                                         groupId: nil,
                                         enabled: false,
                                         date: Calendar.current.date(bySettingHour: 8,
                                                                     minute: 20,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: 10))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "跑步",
                                         groupId: nil,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: 10))

        Groups.instance().addGroup(Group(groupId: NextGroupId, groupLabel: "航站", enabled: true, repeatWeekdays: RepeatWeekdaysProp))
        Groups.instance().addGroup(Group(groupId: NextGroupId, groupLabel: "航務值班", enabled: true, repeatWeekdays: RepeatWeekdaysProp))
        Groups.instance().addGroup(Group(groupId: NextGroupId, groupLabel: "消防值班", enabled: true, repeatWeekdays: RepeatWeekdaysProp))


        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "點早餐",
                                         groupId: 0,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 6,
                                                                     minute: 45,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "打飯",
                                         groupId: 0,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 15,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))

        // 航務值班
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "巡視鳥網",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 8,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 9,
                                            minute: 30,
                                            second: 0,
                                            of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 10,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "吃飯",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 11,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "起床",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 13,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 15,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 16,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "降旗",
                                         groupId: 1,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 5,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))

        // 消防值班
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "訂早餐",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 6,
                                                                     minute: 43,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "訂早餐",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                            minute: 3,
                                            second: 0,
                                            of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "無線電測試",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                            minute: 20,
                                            second: 0,
                                            of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "警鈴測試",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                            minute: 22,
                                            second: 0,
                                            of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 8,
                                            minute: 0,
                                            second: 0,
                                            of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "檢查FOD",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 8,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 9,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 10,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 11,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 11,
                                                                     minute: 15,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 13,
                                                                     minute: 45,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "檢查FOD",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 39,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 50,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 15,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 15,
                                                                     minute: 50,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 16,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().addAlarm(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 2,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 15,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: nil,
                                         soundName: "",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
    }
}

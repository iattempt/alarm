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
var IsLoadedPropertiesOfSelectedAlarmOrGroup: Bool = false
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

class InitViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        initStatic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension InitViewController {
    func initStatic() {
        let _ = Utility()
        let _ = Scheduler()
    }
}

extension InitViewController {
    func requestAuthorization() {
        if !UserDefaults.standard.bool(forKey: "firstLaunched") {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            requestMusicAuthorization()
            requestNotificationAuthorization()

            UserDefaults.standard.set(true, forKey: "firstLaunched")
        }
    }

    fileprivate func requestMusicAuthorization() {
        MPMediaQuery.songs()
    }

    fileprivate func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {(_,_) in}
    }
}

extension InitViewController {
    func loadMyAlarms() {
        NextAlarmId = 0
        NextGroupId = 0
        Alarms.instance().removeAll()
        Groups.instance().removeAll()

        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "起床",
                                         groupId: nil,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 6,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: 10))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "跑步",
                                         groupId: nil,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: 10))
        let 航站 = Group(groupId: NextGroupId, groupLabel: "航站", enabled: true, repeatWeekdays: RepeatWeekdaysProp)
        Groups.instance().add(航站)
        let 航務值班 = Group(groupId: NextGroupId, groupLabel: "航務值班", enabled: true, repeatWeekdays: RepeatWeekdaysProp)
        Groups.instance().add(航務值班)
        let 消防值班 = Group(groupId: NextGroupId, groupLabel: "消防值班", enabled: true, repeatWeekdays: RepeatWeekdaysProp)
        Groups.instance().add(消防值班)


        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "點早餐",
                                         groupId: 航站.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 6,
                                                                     minute: 45,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "打飯",
                                         groupId: 航站.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 15,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))

        // 航務值班
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "巡視鳥網",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 8,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 9,
                                            minute: 30,
                                            second: 0,
                                            of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 10,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "吃飯",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 11,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "起床",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 13,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 15,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "業務",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 16,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "降旗",
                                         groupId: 航務值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 5,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))

        // 消防值班
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "訂早餐",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 6,
                                                                     minute: 43,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "訂早餐",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                            minute: 3,
                                            second: 0,
                                            of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "無線電測試",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                            minute: 20,
                                            second: 0,
                                            of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "警鈴測試",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 7,
                                            minute: 22,
                                            second: 0,
                                            of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 8,
                                            minute: 0,
                                            second: 0,
                                            of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "檢查FOD",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 8,
                                                                     minute: 30,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 9,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 10,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 11,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 11,
                                                                     minute: 15,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 13,
                                                                     minute: 45,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "檢查FOD",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 39,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 14,
                                                                     minute: 50,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 15,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 15,
                                                                     minute: 50,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 16,
                                                                     minute: 0,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
        Alarms.instance().add(Alarm(alarmId: NextAlarmId,
                                         alarmLabel: "廣播",
                                         groupId: 消防值班.groupId,
                                         enabled: true,
                                         date: Calendar.current.date(bySettingHour: 17,
                                                                     minute: 15,
                                                                     second: 0,
                                                                     of: Date())!,
                                         soundId: 1,
                                         soundName: "1.mp3",
                                         vibrateId: nil,
                                         vibrateName: "",
                                         repeatWeekdays: RepeatWeekdaysProp,
                                         snoozeId: nil))
    }
}

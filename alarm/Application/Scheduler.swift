//
//  Scheduler.swift
//  alarm
//
//  Created by Ernest on 04/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import MediaPlayer

class Scheduler {
    init() {
        let snoozeAction = UNNotificationAction(
            identifier: NotificationIdentifiers.AlarmSnoozeAction,
            title: "Snooze",
            options: [.destructive])
        let stopAction = UNNotificationAction(
            identifier: NotificationIdentifiers.AlarmStopAction,
            title: "Stop",
            options: [])

        let snoozeAndStopCategory = UNNotificationCategory(
            identifier: NotificationIdentifiers.SnoozeAndStopCategory,
            actions: [snoozeAction, stopAction],
            intentIdentifiers: [],
            options: [])
        let stopOnlyCategory = UNNotificationCategory(
            identifier: NotificationIdentifiers.StopOnlyCategory,
            actions: [stopAction],
            intentIdentifiers: [],
            options: [])

        UNUserNotificationCenter.current().setNotificationCategories([snoozeAndStopCategory, stopOnlyCategory])
    }

    static func reSetUpAllAlarmNotifications() {
/*
 TODO

 cannot restart snooze alarm after reboot iphone or re-schedule
 */
        for alarm in Alarms.instance().alarms() {
            alarm.setUpNotification()
        }
    }

    static func setUpAlarmNotifications(_ alarm: Alarm) {
        if alarm.isRepeat() {
            setUpAlarmWeekdaysNotifications(alarm)
        } else {
            setUpAlarmOnceNotifications(alarm)
        }
    }

    fileprivate static func setUpAlarmOnceNotifications(_ alarm: Alarm) {
        tearDownAlarmNotifications(alarm)
        let content = UNMutableNotificationContent()
        content.userInfo = ["alarmId": alarm.alarmId, "date": alarm.date]
        setContentTitleForAlarm(content, alarm)
        setContentCategoryForAlarm(content, alarm)
        setContentSoundForAlarm(content, alarm)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: extractComponentFromDate(alarm.date),
            repeats: false)

        let request = UNNotificationRequest(identifier: getOnceIdentifier(alarm),
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let theError = error {
                print(theError)
            }
        }
    }

    private static func setUpAlarmWeekdaysNotifications(_ alarm: Alarm) {
        tearDownAlarmNotifications(alarm)
        var dateComponents = extractComponentFromDate(alarm.date)
        dateComponents.timeZone = Calendar.current.timeZone
        for week in alarm.getRepeatWeekdays() {
            dateComponents.weekday = Week.convertWeekToInt(week)
            setUpAlarmNotificationsForWeekday(
                alarm,
                identifier: getWeekIdentifierForWeek(alarm, week),
                dateComponents: dateComponents)
        }
    }

    private static func setUpAlarmNotificationsForWeekday(
        _ alarm: Alarm, identifier: String, dateComponents: DateComponents) {

        let content = UNMutableNotificationContent()
        content.userInfo = ["identifier": identifier,
                            "alarmId": alarm.alarmId,
                            "date": alarm.date]
        setContentTitleForAlarm(content, alarm)
        setContentCategoryForAlarm(content, alarm)
        setContentSoundForAlarm(content, alarm)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: true)

        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let theError = error {
                print(theError)
            }
        }
    }

    static func tearDownAlarmNotifications(_ alarm: Alarm) {
        tearDownAlarmNotificationsForOnce(alarm)
        tearDownAlarmNotificationsForWeekdays(alarm)
        tearDownAlarmNotificationsForSnooze(alarm)
    }

    private static func tearDownAlarmNotificationsForOnce(_ alarm: Alarm) {
        // remove once
        let identifier = getOnceIdentifier(alarm)
        removePendingNotificationRequestsByIdentifier(identifier)
    }

    private static func tearDownAlarmNotificationsForWeekdays(_ alarm: Alarm) {
        for week in Week.allCases {
            let identifier = getWeekIdentifierForWeek(alarm, week)
            removePendingNotificationRequestsByIdentifier(identifier)
        }
    }

    private static func tearDownAlarmNotificationsForSnooze(_ alarm: Alarm) {
        // remove once
        let identifier = getSnoozeIdentifier(alarm)
        removePendingNotificationRequestsByIdentifier(identifier)
    }

    private static func removePendingNotificationRequestsByIdentifier(_ identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                if notification.identifier == identifier {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(
                        withIdentifiers: [identifier])
                }
            }
        }
    }

    private static func extractComponentFromDate(_ date: Date) -> DateComponents {
        var components = DateComponents()
        components.hour = Calendar.current.component(.hour, from: date)
        components.minute = Calendar.current.component(.minute, from: date)
        return components
    }
}

extension Scheduler {
    private static func getOnceIdentifier(_ alarm: Alarm) -> String {
        return "\(alarm.alarmId)_once"
    }

    private static func getSnoozeIdentifier(_ alarm: Alarm) -> String {
        return "\(alarm.alarmId)_snooze"
    }

    private static func getWeekIdentifierForWeek(_ alarm: Alarm, _ week: Week) -> String {
        return "\(alarm.alarmId)_\(Week.convertWeekCaseToString(week))"
    }

    fileprivate static func setContentTitleForAlarm(_ content: UNMutableNotificationContent, _ alarm: Alarm) {
        content.title = alarm.alarmLabel
    }

    private static func setContentCategoryForAlarm(_ content: UNMutableNotificationContent, _ alarm: Alarm) {
        if let snooze = alarm.snoozeId {
            content.subtitle = "Snooze \(snooze) Min"
            content.categoryIdentifier = NotificationIdentifiers.SnoozeAndStopCategory
        } else {
            content.categoryIdentifier = NotificationIdentifiers.StopOnlyCategory
        }
    }

    private static func setContentSoundForAlarm(_ content: UNMutableNotificationContent, _ alarm: Alarm) {
        if let _ = alarm.soundId {
            content.sound = UNNotificationSound(named: alarm.soundName)
        }
    }
}

/*
 notification delegate
 set up snooze

 TODO:
    1. Set up snooze when user tapped close button or swipe out of notificaiton
    2. Add timer notification for snooze
 */
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO: handle that user tapped close button of notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [response.notification.request.identifier])
        switch response.actionIdentifier {
        case NotificationIdentifiers.AlarmStopAction:
            break
        default:
            let alarmId = response.notification.request.content.userInfo["alarmId"] as! Int
            var alarm = Alarms.instance().alarm(byId: alarmId)
            alarm.date = Utility.unifyDate(Date().addMinutes(alarm.snoozeId!))
            Scheduler.setUpAlarmOnceNotifications(alarm)
        }

        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

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

class SchedulerDelegate: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        var alarm = response.notification.request.content.userInfo["alarm"] as! Alarm

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [response.notification.request.identifier])
        switch response.actionIdentifier {
        case "alarm_stop_action":
            break
        default:
            alarm.date = alarm.date.addMinutes(alarm.snoozeId!)
            Scheduler.setUpAlarmNotifications(alarm)
        }

        completionHandler()
    }
}

class Scheduler {
    static func setUp() {
        setUpCategory()
    }

    private static func setUpCategory() {
        let snoozeAction = UNNotificationAction(identifier: "alarm_snooze_action",
                                                title: "Snooze",
                                                options: [.destructive])
        let stopAction = UNNotificationAction(identifier: "alarm_stop_action",
                                              title: "Stop",
                                              options: [])

        let snoozeAndStopCategory = UNNotificationCategory(identifier: Notification.Name.SnoozeAndStop,
                                                           actions: [snoozeAction, stopAction],
                                                           intentIdentifiers: [],
                                                           options: [])
        let stopOnlyCategory = UNNotificationCategory(identifier: Notification.Name.StopOnly,
                                                      actions: [stopAction],
                                                      intentIdentifiers: [],
                                                      options: [])

        UNUserNotificationCenter.current().setNotificationCategories([snoozeAndStopCategory])
        UNUserNotificationCenter.current().setNotificationCategories([stopOnlyCategory])
    }

    static func setUpAlarmNotifications(_ alarm: Alarm) {
        tearDownNotifications(alarm)
        if alarm.getRepeats().isEmpty {
            setUpAlarmNotificationsOnce(alarm)
        } else {
            setUpAlarmNotificationsRepeatedly(alarm)
        }
    }

    private static func setUpAlarmNotificationsOnce(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = alarm.alarmLabel
        if let _ = alarm.snoozeId {
            content.categoryIdentifier = Notification.Name.SnoozeAndStop
        } else {
            content.categoryIdentifier = Notification.Name.StopOnly
        }
        content.sound = UNNotificationSound.default()
        content.userInfo = ["alarm": alarm]

        let trigger = UNCalendarNotificationTrigger(dateMatching: getComponent(alarm.date),
                                                    repeats: false)

        let request = UNNotificationRequest(identifier: "\(alarm.alarmId)",
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let theError = error {
                print(theError)
            }
        }
    }

    private static func setUpAlarmNotificationsRepeatedly(_ alarm: Alarm) {
        var dateComponents = getComponent(alarm.date)
        dateComponents.timeZone = Calendar.current.timeZone
        for week in alarm.getRepeats() {
            dateComponents.weekday = Week.weekday(week)
            setUpAlarmNotificationsRepeatedlyImpl(
                alarm,
                identifier: "\(alarm.alarmId)_\(Week.convertCaseToString(week))",
                dateComponents: dateComponents)
        }
    }

    private static func setUpAlarmNotificationsRepeatedlyImpl(_ alarm: Alarm,
                                                              identifier: String,
                                                              dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = alarm.alarmLabel
        if let _ = alarm.snoozeId {
            content.categoryIdentifier = Notification.Name.SnoozeAndStop
        } else {
            content.categoryIdentifier = Notification.Name.StopOnly
        }
        content.sound = UNNotificationSound.default()
        content.userInfo = ["identifier": identifier]

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

    static func tearDownNotifications(_ alarm: Alarm) {
        tearDownSnoozeNotifications(alarm)
        tearDownWeekNotifications(alarm)
        tearDownOnceNotifications(alarm)
    }

    static func tearDownSnoozeNotifications(_ alarm: Alarm) {
        // remove once
        let identifier = "\(alarm.alarmId)_snooze"
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                if notification.identifier == identifier {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(
                        withIdentifiers: [identifier])
                    break
                }
            }
        }
    }

    private static func tearDownOnceNotifications(_ alarm: Alarm) {
        // remove once
        let identifier = "\(alarm.alarmId)_once"
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                if notification.identifier == identifier {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(
                        withIdentifiers: [identifier])
                    break
                }
            }
        }
    }

    private static func tearDownWeekNotifications(_ alarm: Alarm) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for week in Week.allCases {
                let identifier = "\(alarm.alarmId)_\(Week.convertCaseToString(week))"
                for notification in notifications {
                    if notification.identifier == identifier {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(
                            withIdentifiers: [identifier])
                        break
                    }
                }
            }
        }
    }

    private static func getComponent(_ date: Date) -> DateComponents {
        var components = DateComponents()
        components.hour = Calendar.current.component(.hour, from: date)
        components.minute = Calendar.current.component(.minute, from: date)
        return components
    }
}


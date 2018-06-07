//
//  EditGroupAlarmViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class EditGroupAlarmViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func Save(_ sender: UIBarButtonItem) {
        let groupAlarm = GroupAlarms.instance()
        let alarm = GroupAlarm(
            groupId: nextGroupId,
            alarms: [Alarm(
                alarmId: nextAlarmId,
                enabled: false,
                label: "Alarm\(nextAlarmId)",
                date: Date(),
                soundId: nil,
                vibrateId: nil,
                snoozeId: nil,
                doesBelongToGroup: nil)],
            enabled: false,
            label: "Group\(nextGroupId)",
            groupSoundId: nil,
            groupVibrateId: nil,
            groupSnoozeId: nil,
            repeatWeekdays: [])
        nextAlarmId += 1
        nextGroupId += 1
        groupAlarm.alarms.append(alarm)
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: .saveAddingGroupAlarm, object: self, userInfo: nil)
        NotificationCenter.default.post(name: .saveAddingGroupAlarmToGroup, object: self, userInfo: nil)
    }
}

extension EditGroupAlarmViewController: UITableViewDelegate,
                                        UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = Label
        case 1:
            cell.textLabel?.text = "Repeat"
        case 2:
            cell.textLabel?.text = "Sound"
        case 3:
            cell.textLabel?.text = "Vibrate"
        case 4:
            cell.textLabel?.text = "Snooze"
        case 5:
            cell.textLabel?.text = GroupLabel
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ga_alarm_label", sender: self)
        case 1:
            performSegue(withIdentifier: "ga_alarm_repeat", sender: self)
        case 2:
            performSegue(withIdentifier: "ga_alarm_sound", sender: self)
        case 3:
            performSegue(withIdentifier: "ga_alarm_vibrate", sender: self)
        case 4:
            performSegue(withIdentifier: "ga_alarm_snooze", sender: self)
        case 5:
            performSegue(withIdentifier: "ga_alarm_group", sender: self)
        default:
            break
        }
    }
}


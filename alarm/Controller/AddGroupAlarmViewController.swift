//
//  AddGroupAlarmViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AddGroupAlarmViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func Save(_ sender: UIBarButtonItem) {
        let alarm = Alarm(
            alarmId: nextAlarmId,
            enabled: false,
            label: "Alarm\(nextAlarmId)",
            date: datePicker.date,
            soundId: nil,
            vibrateId: nil,
            snoozeId: nil,
            doesBelongToGroup: nil)

        if SelectedHomoAlarmsId != nil {
            saveEditing(alarm)
        } else {
            saveAdding(alarm)
        }

        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    fileprivate func saveEditing(_ alarm: Alarm) {
        //To be implemented
        var homoAlarms = HomogenousModel.instance().homoAlarms
        for (index, groupAlarm) in homoAlarms.enumerated() {
            if groupAlarm.homoId == SelectedHomoAlarmsId {
                homoAlarms[index].alarms.append(alarm)
            }
        }
        nextAlarmId += 1
        HomogenousModel.instance().homoAlarms = homoAlarms
    }

    fileprivate func saveAdding(_ alarm: Alarm) {
        //To be implemented
        let homoAlarm = HomoAlarm(
            homoId: nextGroupId,
            alarms: [alarm],
            enabled: false,
            label: "Homo\(SelectedHomoAlarmsId ?? nextGroupId)",
            groupSoundId: nil,
            groupVibrateId: nil,
            groupSnoozeId: nil,
            repeatWeekdays: [])
        nextAlarmId += 1
        nextGroupId += 1
        HomogenousModel.instance().homoAlarms.append(homoAlarm)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SelectedHomoAlarmId = nil
        NotificationCenter.default.post(name: .saveGroupAlarm, object: self, userInfo: nil)
        NotificationCenter.default.post(name: .saveGroupAlarmToGroup, object: self, userInfo: nil)
    }
}

extension AddGroupAlarmViewController: UITableViewDelegate,
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
            cell.textLabel?.text = "Label"
        case 1:
            cell.textLabel?.text = "Repeat"
        case 2:
            cell.textLabel?.text = "Sound"
        case 3:
            cell.textLabel?.text = "Vibrate"
        case 4:
            cell.textLabel?.text = "Snooze"
        case 5:
            cell.textLabel?.text = "GroupLabel"
        default:
            break
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

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

//        let alert = UIAlertController(title: "Confirm", message: "Do you sure that?", preferredStyle: UIAlertControllerStyle.actionSheet)
//        let leave = UIAlertAction(title: "Leave", style: UIAlertActionStyle.default, handler:  {(action: UIAlertAction!) -> Void in
//            self.dismiss(animated: true, completion: nil)
//        })
//        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
//        alert.addAction(leave)
//        alert.addAction(cancel)
//        present(alert, animated: true, completion: nil)

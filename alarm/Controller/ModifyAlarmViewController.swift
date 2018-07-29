//
//  ModifyAlarmViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class ModifyAlarmViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func save(_ sender: Any) {
        if let theAlarm = SelectedAlarm {
            updateAlarm(theAlarm)
        } else {
            addAlarm()
        }

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("adding/editing alarm will appear")
        super.viewWillAppear(animated)
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        debugPrint("adding/editing alarm will disappear")
        super.viewDidDisappear(animated)
    }
}

extension ModifyAlarmViewController: UITableViewDataSource,
                                     UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupIdProp != nil ? 5 : 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Label"
            cell.detailTextLabel?.text = LabelProp
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        case 1:
            cell.textLabel?.text = "Group Label"
            if GroupIdProp != nil {
                cell.detailTextLabel?.text = Groups.instance().group(byId: GroupIdProp!).groupLabel
                cell.detailTextLabel?.textAlignment = NSTextAlignment.right
            }
        case 2:
            cell.textLabel?.text = "Snooze"
            if let min = SnoozeIdProp {
                cell.detailTextLabel?.text = "\(min) minute"
                if min > 1 {
                    cell.detailTextLabel?.text = (cell.detailTextLabel?.text)! + "s"
                }
            }
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        case 3:
            cell.textLabel?.text = "Sound"
            cell.detailTextLabel?.text = SoundIdProp == nil ? "" : SoundNameProp
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        case 4:
            cell.textLabel?.text = "Vibrate"
            cell.detailTextLabel?.text = VibrateIdProp == nil ? "" : VibrateNameProp
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        case 5:
            cell.textLabel?.text = "Repeat"
            cell.detailTextLabel?.text = Week.convertToDisplayingString(RepeatWeekdaysProp)
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        default:
            break
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: performSegue(withIdentifier: "alarm_label", sender: self)
        case 1: performSegue(withIdentifier: "alarm_group_label", sender: self)
        case 2: performSegue(withIdentifier: "alarm_snooze", sender: self)
        case 3: performSegue(withIdentifier: "alarm_sound", sender: self)
        case 4: performSegue(withIdentifier: "alarm_vibrate", sender: self)
        case 5: performSegue(withIdentifier: "alarm_repeat", sender: self)
        default: break
        }
    }
}

extension ModifyAlarmViewController {
    func updateAlarm(_ alarm : Alarm) {
        var theAlarm = alarm
        theAlarm.alarmLabel = LabelProp
        theAlarm.groupId = GroupIdProp
        theAlarm.date = datePicker.date
        theAlarm.soundId = SoundIdProp
        theAlarm.soundName = SoundNameProp
        theAlarm.vibrateId = VibrateIdProp
        theAlarm.vibrateName = VibrateNameProp
        theAlarm.repeatWeekdays = RepeatWeekdaysProp
        theAlarm.snoozeId = SnoozeIdProp
        Alarms.instance().updateAlarm(theAlarm)
    }

    func addAlarm() {
        let alarm = Alarm(alarmId: AlarmIdProp,
                          alarmLabel: LabelProp,
                          groupId: GroupIdProp,
                          enabled: true,
                          date: datePicker.date,
                          soundId: SoundIdProp,
                          soundName: SoundNameProp,
                          vibrateId: VibrateIdProp,
                          vibrateName: VibrateNameProp,
                          repeatWeekdays: RepeatWeekdaysProp,
                          snoozeId: SnoozeIdProp)
        Alarms.instance().addAlarm(alarm)
    }

    func refresh() {
        self.tabBarController?.tabBar.isHidden = true
        loadProperties(alarm: SelectedAlarm, group: SelectedGroup)
        tableView.reloadData()
    }

    func loadProperties(alarm: Alarm?, group: Group?) {
        if !IsLoadedProperties {
            if let alarm = alarm {
                AlarmIdProp = alarm.alarmId
                GroupIdProp = alarm.groupId
                LabelProp = alarm.alarmLabel
                datePicker.date = alarm.date
                SoundIdProp = alarm.soundId
                SoundNameProp = alarm.soundName
                VibrateIdProp = alarm.vibrateId
                VibrateNameProp = alarm.vibrateName
                RepeatWeekdaysProp = alarm.repeatWeekdays
                SnoozeIdProp = alarm.snoozeId
            } else {
                AlarmIdProp = NextAlarmId
                if let group = group {
                    GroupIdProp = group.groupId
                } else {
                    GroupIdProp = nil
                }
                LabelProp = "Label"
                SoundIdProp = nil
                SoundNameProp = "none"
                VibrateIdProp = nil
                VibrateNameProp = "none"
                RepeatWeekdaysProp.removeAll()
                // snooze after 10 minutes
                SnoozeIdProp = 10
            }
        }
        IsLoadedProperties = true
    }
}

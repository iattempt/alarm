//
//  EditDisperseAlarmViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class EditDisperseAlarmViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //        let alert = UIAlertController(title: "Confirm", message: "Do you sure that?", preferredStyle: UIAlertControllerStyle.actionSheet)
        //        let leave = UIAlertAction(title: "Leave", style: UIAlertActionStyle.default, handler:  {(action: UIAlertAction!) -> Void in
        //            self.dismiss(animated: true, completion: nil)
        //        })
        //        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        //        alert.addAction(leave)
        //        alert.addAction(cancel)
        //        present(alert, animated: true, completion: nil)
    }

    @IBAction func Save(_ sender: Any) {
        let disperseAlarm = DisperseAlarms.instance()
        let alarm = DisperseAlarm(
            alarm: Alarm(
                alarmId: nextAlarmId,
                enabled: false,
                label: "Alarm\(nextAlarmId)",
                date: Date(),
                soundId: nil,
                vibrateId: nil,
                snoozeId: nil,
                doesBelongToGroup: nil),
            repeatWeekdays: [])
        nextAlarmId += 1
        disperseAlarm.alarms.append(alarm)
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
        NotificationCenter.default.post(name: .saveAddingDisperseAlarm, object: self, userInfo: nil)
    }
}

extension EditDisperseAlarmViewController: UITableViewDataSource,
                                           UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "alarm_label", sender: self)
        case 1:
            performSegue(withIdentifier: "alarm_repeat", sender: self)
        case 2:
            performSegue(withIdentifier: "alarm_sound", sender: self)
        case 3:
            performSegue(withIdentifier: "alarm_vibrate", sender: self)
        case 4:
            performSegue(withIdentifier: "alarm_snooze", sender: self)
        default:
            break
        }
    }
}


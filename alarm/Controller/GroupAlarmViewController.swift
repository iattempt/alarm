//
//  GroupAlarmViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class GroupAlarmViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("alarms of group will appear")
        super.viewWillAppear(animated)
        refresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        debugPrint("alarms of group will disappear")
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_group_alarm" {
            let dist = segue.destination as! ModifyAlarmViewController
            dist.navigationItem.title = "Edit Alarm"
        }
    }
}


extension GroupAlarmViewController: UITableViewDelegate,
                                    UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let alarms = Alarms.instance().alarms(byGroupId: (SelectedGroup?.groupId)!)
        return alarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theAlarm = Alarms.instance().alarms(byGroupId: (SelectedGroup?.groupId)!)[indexPath.row]
        let switchButton = UISwitch()
        switchButton.isOn = theAlarm.enabled
        switchButton.tag = indexPath.row
        switchButton.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = Utility.dateFormatter.string(from: theAlarm.date)
        cell.detailTextLabel?.text = "\(Groups.instance().group(byId: theAlarm.groupId!).groupLabel):\(theAlarm.alarmLabel)"
        cell.accessoryView = switchButton
        cell.editingAccessoryType = .disclosureIndicator

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedAlarm = Alarms.instance().alarms(byGroupId: (SelectedGroup?.groupId)!)[indexPath.row]
        GroupIdProp = SelectedGroup?.groupId
        doesUpdateAlarm = true
        performSegue(withIdentifier: "edit_group_alarm", sender: self)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let theAlarm = Alarms.instance().alarms(byGroupId: (SelectedGroup?.groupId)!)[indexPath.row]
            Alarms.instance().deleteAlarm(theAlarm)
            refresh()
        }
    }
}

extension GroupAlarmViewController {
    @objc fileprivate func handler(_ notification: Notification) {
        refresh()
    }

    fileprivate func refresh() {
        tableView.allowsSelectionDuringEditing = true
        doesUpdateAlarm = false
        isGroup = true
        SelectedAlarm = nil
        isInitialized = false
        self.tabBarController?.tabBar.isHidden = true
        tableView.reloadData()
        refreshItems()
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        var theAlarm = Alarms.instance().alarms(byGroupId: (SelectedGroup?.groupId)!)[sender.tag]
        theAlarm.enabled = sender.isOn
        Alarms.instance().updateAlarm(theAlarm)
    }

    fileprivate func refreshItems() {
        if !tableView.visibleCells.isEmpty &&
            self.navigationItem.rightBarButtonItems?.count == 1 { 
            self.navigationItem.rightBarButtonItems?.append(editButtonItem)
        } else if tableView.visibleCells.isEmpty &&
            self.navigationItem.rightBarButtonItems?.count == 2 {
            self.navigationItem.rightBarButtonItems?.remove(at: 1)
        }
    }
}

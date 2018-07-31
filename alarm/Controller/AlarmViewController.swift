//
//  AlertViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

fileprivate enum FilterStatus {
    case All
    case On
    case Off
}

class AlarmViewController: UIViewController {
    var alarms = Alarms.instance().alarms()
    @IBOutlet weak var tableView: UITableView!
    fileprivate var filter_status_type: FilterStatus = .On
    // nil means all
    // [-1] means non-group alarms
    var filter_groups: [Int]? = nil

    @IBAction func filter_status(_ sender: UISegmentedControl) {
        let string = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        switch string.lowercased() {
        case "all":
            filter_status_type = FilterStatus.All
        case "on":
            filter_status_type = FilterStatus.On
        case "off":
            filter_status_type = FilterStatus.Off
        default:
            break
        }
        tableView.reloadData()
    }

    @IBAction func filter_group(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Filter", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "All", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.filter_groups = nil
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Not belongs group", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.filter_groups = [-1]
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Enabled group", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.filter_groups = []
            for group in Groups.instance().groups() {
                if group.enabled {
                    self.filter_groups?.append(group.groupId)
                }
            }
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Disabled group", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.filter_groups = []
            for group in Groups.instance().groups() {
                if !group.enabled {
                    self.filter_groups?.append(group.groupId)
                }
            }
            self.tableView.reloadData()
        }))
        for group in Groups.instance().groups() {
            alertController.addAction(UIAlertAction(title: group.groupLabel, style: .default, handler: { (action) in
                self.filter_groups = []
                self.filter_groups?.append(group.groupId)
                self.tableView.reloadData()
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
        }))
        self.present(alertController, animated: true) {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("alarms will appear")
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name.switchGroup, object: nil)
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("alarms will disappear")
        super.viewWillDisappear(animated)
        setEditing(false, animated: false)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_alarm" {
            let dist = segue.destination as! ModifyAlarmViewController
            dist.navigationItem.title = "Edit Alarm"
        }
    }
}

extension AlarmViewController: UITableViewDelegate,
                               UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarms.count
    }

    fileprivate func isMatchingFilterStatus(_ theAlarm: Alarm) -> Bool {
        return filter_status_type == .All ||
               (filter_status_type == .On && theAlarm.isEnabled()) ||
               (filter_status_type == .Off && theAlarm.isDisabled())
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let theAlarm = self.alarms[indexPath.row]
        if isMatchingFilterStatus(theAlarm) && isMatchingFilterGroup(theAlarm) {
            return UITableViewAutomaticDimension
        } else {
            return CGFloat(0)
        }
    }

    fileprivate func isMatchingFilterGroup(_ theAlarm: Alarm) -> Bool {
        // nil means all
        if let theFilterGroupIds = filter_groups {
            // empty means non-group alarms
            if theFilterGroupIds.count == 1 && theFilterGroupIds[0] == -1 {
                if theAlarm.groupId != nil {
                    return false
                }
            } else {
                if let theGroupId = theAlarm.groupId {
                    var matched = false
                    for groupId in theFilterGroupIds {
                        if theGroupId == groupId {
                            matched = true
                        }
                    }
                    return matched
                } else {
                    return false
                }
            }
        }
        return true
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Todo: the animation is not smooth
        let theAlarm = self.alarms[indexPath.row]

        let switchButton = UISwitch()
        switchButton.isOn = theAlarm.isEnabled()
        switchButton.tag = theAlarm.alarmId
        switchButton.isEnabled = !theAlarm.isGroupAlarm() || theAlarm.isGroupEnabled()
        switchButton.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = Utility.dateFormatter.string(from: theAlarm.date)
        cell.tag = theAlarm.alarmId
        cell.detailTextLabel?.text = theAlarm.getLabel()
        cell.accessoryView = switchButton
        cell.editingAccessoryType = .disclosureIndicator

        if !isMatchingFilterStatus(theAlarm){
            cell.isHidden = true
        }

        if !isMatchingFilterGroup(theAlarm) {
            cell.isHidden = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarmId = tableView.cellForRow(at: indexPath)?.tag
        SelectedAlarm = Alarms.instance().alarm(byId: alarmId!)
        if isEditing {
            performSegue(withIdentifier: SegueIdentifiers.EditAlarm, sender: self)
        } else {
//            performSegue(withIdentifier: "later", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarmId = tableView.cellForRow(at: indexPath)?.tag
            let theAlarm = Alarms.instance().alarm(byId: alarmId!)
            Alarms.instance().remove(theAlarm)
            refresh()
        }
    }
}

extension AlarmViewController {
    @objc func refresh() {
        alarms = Alarms.instance().alarms()
        SelectedAlarm = nil

        IsLoadedPropertiesOfSelectedAlarmOrGroup = false
        tableView.reloadData()
        refreshItems()
        self.tabBarController?.tabBar.isHidden = false
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        var theAlarm = Alarms.instance().alarm(byId: sender.tag)
        theAlarm.enabled = sender.isOn
        Alarms.instance().update(theAlarm)
        refresh()
    }

    func refreshItems() {
        if !tableView.visibleCells.isEmpty &&
            navigationItem.rightBarButtonItems?.count == 1 {
            let item = editButtonItem
            item.tintColor = UIColor.black
            navigationItem.rightBarButtonItems?.append(item)
        } else if tableView.visibleCells.isEmpty &&
            navigationItem.rightBarButtonItems?.count == 2 {
            navigationItem.rightBarButtonItems?.remove(at: 1)
        }
    }
}

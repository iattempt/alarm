//
//  ModifyGroupViewController.swift
//  alarm
//
//  Created by Ernest on 04/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class ModifyGroupViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    @IBAction func save(_ sender: UIBarButtonItem) {
        if doesUpdateGroup {
            updateGroup()
        } else {
            addGroup()
        }

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("adding/editing group will appear")
        super.viewWillAppear(animated)
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        debugPrint("adding/editing group will disappear")
        super.viewDidDisappear(animated)
    }
}

extension ModifyGroupViewController: UITableViewDataSource,
                                     UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectedGroup != nil ? 3 : 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Group Label"
            cell.detailTextLabel?.text = LabelProp
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        case 1:
            cell.textLabel?.text = "Repeat"
            cell.detailTextLabel?.text = Utility.convertRepeatToString(RepeatWeekdaysProp)
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        case 2:
            cell.textLabel?.text = "Alarms"
        default:
            break
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "group_label", sender: self)
        case 1:
            performSegue(withIdentifier: "group_repeat", sender: self)
        case 2:
            performSegue(withIdentifier: "group_alarms", sender: self)
        default:
            break
        }
    }
}

extension ModifyGroupViewController {
    func updateGroup() {
        SelectedGroup?.groupLabel = LabelProp
        SelectedGroup?.repeatWeekdays = RepeatWeekdaysProp
        Groups.instance().updateGroup(SelectedGroup!)
    }

    func addGroup() {
        let group = Group(groupId: GroupIdProp!,
                          groupLabel: LabelProp,
                          enabled: true,
                          repeatWeekdays: RepeatWeekdaysProp)
        Groups.instance().addGroup(group)
    }

    func refresh() {
        self.tabBarController?.tabBar.isHidden = true
        loadProperties(group: SelectedGroup)
        tableView.reloadData()
    }

    func loadProperties(group: Group?) {
        if !isInitialized {
            if let group = group {
                LabelProp = group.groupLabel
                GroupIdProp = group.groupId
                RepeatWeekdaysProp = group.repeatWeekdays
            } else {
                LabelProp = "Label"
                GroupIdProp = nextGroupId
                for day in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"] {
                    RepeatWeekdaysProp[day] = false
                }
            }
        }
        isInitialized = true
    }
}

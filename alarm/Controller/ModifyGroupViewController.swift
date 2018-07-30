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
        if let theGroup = SelectedGroup {
            updateGroup(theGroup)
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
        return 2
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
            cell.detailTextLabel?.text = Week.convertWeekdaysToStringForDisplaying(RepeatWeekdaysProp)
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
        default:
            break
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: SegueIdentifiers.GroupLabel, sender: self)
        case 1:
            performSegue(withIdentifier: SegueIdentifiers.GroupRepeat, sender: self)
        default:
            break
        }
    }
}

extension ModifyGroupViewController {
    func updateGroup(_ group: Group) {
        var theGroup = group
        theGroup.groupLabel = LabelProp
        theGroup.enabled = true
        theGroup.repeatWeekdays = RepeatWeekdaysProp
        Groups.instance().update(theGroup)
    }

    func addGroup() {
        let group = Group(groupId: GroupIdProp!,
                          groupLabel: LabelProp,
                          enabled: true,
                          repeatWeekdays: RepeatWeekdaysProp)
        Groups.instance().add(group)
    }

    func refresh() {
        self.tabBarController?.tabBar.isHidden = true
        loadProperties(group: SelectedGroup)
        tableView.reloadData()
    }

    func loadProperties(group: Group?) {
        if !IsLoadedPropertiesOfSelectedAlarmOrGroup {
            if let theGroup = group {
                LabelProp = theGroup.groupLabel
                GroupIdProp = theGroup.groupId
                RepeatWeekdaysProp = theGroup.repeatWeekdays
            } else {
                LabelProp = "Label"
                GroupIdProp = NextGroupId
                RepeatWeekdaysProp.removeAll()
            }
        }
        IsLoadedPropertiesOfSelectedAlarmOrGroup = true
    }
}

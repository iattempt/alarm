//
//  GroupViewController.swift
//  alarm
//
//  Created by Ernest on 04/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("groups organization will appear")
        super.viewWillAppear(animated)
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("groups will disappear")
        super.viewWillDisappear(animated)
        setEditing(false, animated: false)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_group" {
            let dist = segue.destination as! ModifyGroupViewController
            dist.navigationItem.title = "Edit Group"
        }
    }
}

extension GroupViewController: UITableViewDelegate,
                                       UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groups = Groups.instance().groups()
        return groups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theGroup = Groups.instance().groups()[indexPath.row]

        let switchButton = UISwitch()
        switchButton.isOn = theGroup.enabled
        switchButton.tag = indexPath.row
        switchButton.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = theGroup.groupLabel
        cell.accessoryView = switchButton
        cell.editingAccessoryType = .detailDisclosureButton

        return cell
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        doesUpdateGroup = true
        SelectedGroup = Groups.instance().groups()[indexPath.row]
        performSegue(withIdentifier: "edit_group", sender: self)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title:"Warning",
                                          message:"All alarms in the group will be deleted too. Are you sure want to do this?",
                                          preferredStyle:.alert)
            let cancel=UIAlertAction(title:"Cancel", style:.cancel)
            let confirm=UIAlertAction(title:"Confirm", style:.default) { (action) in
                let theGroup = Groups.instance().groups()[indexPath.row]
                let theAlarmsOfTheGroup = Alarms.instance().alarms(byGroupId: theGroup.groupId)
                for alarm in theAlarmsOfTheGroup {
                    Alarms.instance().deleteAlarm(alarm)
                }
                Groups.instance().deleteGroup(theGroup)
                self.refresh()
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension GroupViewController {
    @objc fileprivate func handler(_ notification: Notification) {
        refresh()
    }

    fileprivate func refresh() {
        isGroup = true
        doesUpdateGroup = false
        SelectedGroup = nil
        isInitialized = false
        tableView.reloadData()
        refreshItems()
        self.tabBarController?.tabBar.isHidden = false
    }

    @objc func switchChanged(_ sender: UISwitch!) {
        var theGroup = Groups.instance().groups()[sender.tag]
        theGroup.enabled = sender.isOn
        Groups.instance().updateGroup(theGroup)
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

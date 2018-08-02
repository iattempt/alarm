//
//  AlarmGroupViewController.swift
//  alarm
//
//  Created by Ernest on 03/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmGroupViewController: UIViewController {
    var groups = Groups.instance().groups()

    @IBOutlet weak var tableView: UITableView!

    @IBAction func addGroup(_ sender: UIBarButtonItem) {
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("selecting group will appear")
        super.viewWillAppear(animated)
        refresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("selecting group will disappear")
        super.viewWillDisappear(animated)
        setEditing(false, animated: false)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

extension AlarmGroupViewController: UITableViewDelegate,
                                    UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groups = Groups.instance().groups()
        let cell = UITableViewCell()
        cell.tintColor = UIColor.black
        if groups.isEmpty {
            cell.editingAccessoryType = .none
        } else {
            let theGroup = groups[indexPath.row]

            cell.textLabel?.text = theGroup.groupLabel
            cell.editingAccessoryType = .disclosureIndicator

            // reload
            if GroupIdProp != nil && theGroup.groupId == GroupIdProp! {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            SelectedGroup = self.groups[indexPath.row]
            performSegue(withIdentifier: "edit_group", sender: self)
            let selectedRow = tableView.cellForRow(at: indexPath)
            selectedRow?.backgroundColor = UIColor.clear
        } else {
            if tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark {
                GroupIdProp = Groups.instance().groups()[indexPath.row].groupId
            } else {
                GroupIdProp = nil
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
}

extension AlarmGroupViewController {
    func refresh() {
        tableView.allowsSelectionDuringEditing = true
        self.groups = Groups.instance().groups()
        tableView.reloadData()
    }
}

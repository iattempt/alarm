//
//  AlarmGroupViewController.swift
//  alarm
//
//  Created by Ernest on 03/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmGroupViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

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
    }
}

extension AlarmGroupViewController: UITableViewDelegate,
                                    UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Groups.instance().groups().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groups = Groups.instance().groups()
        let cell = UITableViewCell()
        if groups.isEmpty {
            cell.editingAccessoryType = .none
        } else {
            let theGroup = groups[indexPath.row]

            cell.textLabel?.text = theGroup.groupLabel
            cell.editingAccessoryType = .detailDisclosureButton

            // reload
            if GroupIdProp != nil && theGroup.groupId == GroupIdProp! {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark {
            GroupIdProp = Groups.instance().groups()[indexPath.row].groupId
        } else {
            GroupIdProp = nil
        }
        tableView.reloadData()
    }
}

extension AlarmGroupViewController {
    fileprivate func refresh() {
        tableView.reloadData()
    }
}

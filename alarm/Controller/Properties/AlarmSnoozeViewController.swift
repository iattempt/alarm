//
//  AlarmSnoozeViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmSnoozeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("selecting snooze will appear")
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("selecting snooze will disappear")
        super.viewWillDisappear(animated)
    }
}

extension AlarmSnoozeViewController: UITableViewDelegate,
UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 61
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "snooze_cell", for: indexPath) as! SnoozeTableViewCell
        if indexPath.row == 0 {
            cell.label.text = "none"
            cell.accessoryType = SnoozeIdProp == nil ? .checkmark : .none
        } else {
            let min = indexPath.row
            cell.label.text = "\(min) minute"
            if min > 1 {
                cell.label.text = cell.label.text! + "s"
            }
            cell.accessoryType = SnoozeIdProp == indexPath.row ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SnoozeIdProp = indexPath.row == 0 ? nil : indexPath.row
        tableView.reloadData()
    }
}

//
//  AlarmRepeatViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmRepeatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("selecting repeat will appear")
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("selecting repeat will disappear")
        super.viewWillDisappear(animated)
    }
}

extension AlarmRepeatViewController: UITableViewDelegate,
                                     UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Sunday"
        case 1:
            cell.textLabel?.text = "Monday"
        case 2:
            cell.textLabel?.text = "Tuesday"
        case 3:
            cell.textLabel?.text = "Wednesday"
        case 4:
            cell.textLabel?.text = "Thursday"
        case 5:
            cell.textLabel?.text = "Friday"
        case 6:
            cell.textLabel?.text = "Saturday"
        default:
            break
        }
        cell.accessoryType = .none

        // reload
        if let enable = RepeatWeekdaysProp[(cell.textLabel?.text)!] {
            cell.accessoryType = enable ? .checkmark : .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = tableView.cellForRow(at: indexPath)?.textLabel?.text
        RepeatWeekdaysProp[day!] = !RepeatWeekdaysProp[day!]!
        tableView.reloadData()
    }
}

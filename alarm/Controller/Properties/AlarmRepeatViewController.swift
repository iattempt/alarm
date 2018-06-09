//
//  AlarmRepeatViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmRepeatViewController: UIViewController {
    var repeatWeekdaysInfo = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
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
        return repeatWeekdaysInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = repeatWeekdaysInfo[indexPath.row]
        // reload
        if let enable = RepeatWeekdaysProp[(cell.textLabel?.text)!] {
            cell.accessoryType = enable ? .checkmark : .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = tableView.cellForRow(at: indexPath)?.textLabel?.text
        guarenteeRepeatWeekdays()
        RepeatWeekdaysProp[day!] = !RepeatWeekdaysProp[day!]!
        tableView.reloadData()
    }
}

extension AlarmRepeatViewController {
    func guarenteeRepeatWeekdays() {
        for day in repeatWeekdaysInfo {
            if !RepeatWeekdaysProp.keys.contains(day) {
                RepeatWeekdaysProp[day] = false
            }
        }
    }
}

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
        return Week.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.tintColor = UIColor.black
        cell.textLabel?.text = Week.convertWeekCaseToString(Week(rawValue: indexPath.row + 1)!)
        if RepeatWeekdaysProp.contains(Week.convertWeekStringToCase((cell.textLabel?.text)!)) {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let week = Week.convertWeekStringToCase((tableView.cellForRow(at: indexPath)?.textLabel?.text)!)
        if RepeatWeekdaysProp.contains(week) {
            for (i, w) in RepeatWeekdaysProp.enumerated() {
                if w == week {
                    RepeatWeekdaysProp.remove(at: i)
                }
            }
        } else {
            RepeatWeekdaysProp.append(week)
        }
        tableView.reloadData()
    }
}

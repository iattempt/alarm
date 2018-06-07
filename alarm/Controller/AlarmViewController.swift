//
//  AlertViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {
    var alarms = Alarms.instance().alarms()

    @IBOutlet weak var tableView: UITableView!
    var filterType: String = "All"

    @IBAction func filter(_ sender: UISegmentedControl) {
        filterType = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        tableView.reloadData()
    }

    @IBAction func add(_ sender: Any) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("alarms will appear")
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("alarms will disappear")
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let theAlarm = self.alarms[indexPath.row]
        if (filterType == "On" && !theAlarm.isEnabled()) ||
            (filterType == "Off" && !theAlarm.isDisabled()){
            return CGFloat(0)
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theAlarm = self.alarms[indexPath.row]
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)

        // Todo: the animation is not smooth
        if (filterType == "On" && !theAlarm.isEnabled()) ||
            (filterType == "Off" && !theAlarm.isDisabled()){
            cell.isHidden = true
        } else {
            cell.textLabel?.text = Utility.dateFormatter.string(from: theAlarm.date)
            if let groupId = theAlarm.groupId {
                cell.detailTextLabel?.text = "\(Groups.instance().group(byId: groupId).groupLabel):\(theAlarm.alarmLabel)"
            } else {
                cell.detailTextLabel?.text = theAlarm.alarmLabel
            }
            cell.accessoryType = .detailDisclosureButton
        }

        return cell
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        SelectedAlarm = self.alarms[indexPath.row]
        performSegue(withIdentifier: "later", sender: self)
    }
}

extension AlarmViewController {
    func refresh() {
        alarms = Alarms.instance().alarms()
        isInitialized = false
        doesUpdateAlarm = false
        isGroup = false
        SelectedAlarm = nil
        tableView.reloadData()
    }
}

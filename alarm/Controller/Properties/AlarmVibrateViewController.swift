//
//  AlarmVibrateViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit
import MediaPlayer
import AudioToolbox

class AlarmVibrateViewController: UIViewController {
    var timer = Timer()
    var systemSoundID = SystemSoundID(4095)
    var times = 0
    @IBOutlet weak var tableView: UITableView!

    @objc func scheduleStartVibrate() {
        DispatchQueue.main.async {
            self.startVibrate()
            if self.times < 3 {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.scheduleStartVibrate), userInfo: nil, repeats: false)
            }
        }
    }

    @objc func scheduleStopVibrate() {
        DispatchQueue.main.async {
            if self.times >= 3 {
                self.stopVibrate()
            } else if self.timer.isValid {
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.scheduleStopVibrate), userInfo: nil, repeats: false)
            }
        }
    }

    @objc func startVibrate() {
        self.times += 1
        AudioServicesPlayAlertSound(self.systemSoundID)
        print(self.times)
    }

    @objc func stopVibrate() {
        self.times = 0
        self.timer.invalidate()
        self.timer = Timer()
        print("stopped")
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("selecting vibrate will appear")
        super.viewWillAppear(animated)
        self.systemSoundID = 1011
        startVibrate()
        self.systemSoundID = 1311
        startVibrate()
        self.systemSoundID = 1311
        startVibrate()


//        not working in device-testing mode
//        AudioServicesPlaySystemSound(1519)
//        AudioServicesPlaySystemSound(1520)
//        AudioServicesPlaySystemSound(1521)
//        UINotificationFeedbackGenerator().notificationOccurred(.error)
//        UINotificationFeedbackGenerator().notificationOccurred(.success)
//        UINotificationFeedbackGenerator().notificationOccurred(.warning)
//        UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.light).impactOccurred()
//        UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.heavy).impactOccurred()
//        UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.medium).impactOccurred()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("selecting vibrate will disappear")
        super.viewWillDisappear(animated)
        self.stopVibrate()
    }
}

extension AlarmVibrateViewController: UITableViewDelegate,
UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Normal"
        cell.tintColor = UIColor.black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            self.stopVibrate()
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            if self.times == 0 {
                // choose other vibrate type here
                self.systemSoundID = SystemSoundID(4095)
                scheduleStartVibrate()
                scheduleStopVibrate()
            }
        }
    }
}

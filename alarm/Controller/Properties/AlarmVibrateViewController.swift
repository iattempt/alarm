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
    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("selecting vibrate will appear")
        super.viewWillAppear(animated)
        // not working in device-testing mode
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
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
        return UITableViewCell()
    }
}

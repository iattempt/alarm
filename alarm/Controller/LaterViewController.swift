//
//  LaterViewController.swift
//  alarm
//
//  Created by Ernest on 03/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class LaterViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBAction func pick(_ sender: Any) {
    }

    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func save(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("push back will appear")
        datePicker.date = (SelectedAlarm?.date)!
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        debugPrint("push back will disappear")
        SelectedAlarm = nil
    }
}

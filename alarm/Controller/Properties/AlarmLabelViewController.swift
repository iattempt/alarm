//
//  AlarmLabelViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit

class AlarmLabelViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelViewBottomLayoutConstraint: NSLayoutConstraint!

    @IBAction func type(_ sender: UITextField) {
        if sender.text != nil, sender.text != "" {
            LabelProp = sender.text!
        } else {
            LabelProp = "Label"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("editing label will appear")
        super.viewWillAppear(animated)
        textField.text = LabelProp
        textField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        debugPrint("editing label will disappear")
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}

extension AlarmLabelViewController {
    @objc func keyboardWillAppear(notification: NSNotification?) {
        guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }

        textFieldViewBottomLayoutConstraint.constant = keyboardHeight - self.view.frame.size.height / 2
        labelViewBottomLayoutConstraint.constant = keyboardHeight - self.view.frame.size.height / 2
    }

    @objc func keyboardWillDisappear(notification: NSNotification?) {
        textFieldViewBottomLayoutConstraint.constant = 0.0
        labelViewBottomLayoutConstraint.constant = 0.0
    }
}

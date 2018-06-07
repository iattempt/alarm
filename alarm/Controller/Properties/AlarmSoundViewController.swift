//
//  AlarmSoundViewController.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class AlarmSoundViewController: UIViewController {
    var isSelectedToPlay = false
    var isFailedToAccessMusic = false

    @IBOutlet weak var tableView: UITableView!

    var items: [MPMediaItem] = [MPMediaItem]()

    override func viewWillAppear(_ animated: Bool) {
        debugPrint("selecting sound will appear")
        super.viewWillAppear(animated)
        refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseMusic), name: NSNotification.Name.UIApplicationWillResignActive, object: nil    )
        NotificationCenter.default.addObserver(self, selector: #selector(popViewControllerDueToFailedToAccessMusic), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    @objc func pauseMusic() {
        if isSelectedToPlay {
            MPMusicPlayerController.systemMusicPlayer.pause()
        }
        isSelectedToPlay = false
    }

    @objc func popViewControllerDueToFailedToAccessMusic() {
        if isFailedToAccessMusic {
            self.navigationController?.popViewController(animated: true)
        }
        isFailedToAccessMusic = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        debugPrint("selecting sound will disappear")
        super.viewWillDisappear(animated)
        pauseMusic()
    }
}

extension AlarmSoundViewController: UITableViewDelegate,
UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = MPMediaQuery.songs().items {
            return items.count + 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            cell.textLabel?.text = "none"
            cell.accessoryType = SoundIdProp == nil ? .checkmark : .none
        } else {
            let item = items[indexPath.row - 1]
            cell.textLabel?.text = item.title
            cell.tag = indexPath.count
            cell.accessoryType = SoundIdProp == item.persistentID ? .checkmark : .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            SoundIdProp = nil
            SoundNameProp = "none"
        } else {
            let index = indexPath.row - 1
            SoundIdProp = self.items[index].persistentID
            SoundNameProp = self.items[index].title!
            isSelectedToPlay = true
            MPMusicPlayerController.systemMusicPlayer.setQueue(with: MPMediaItemCollection(items: [self.items[index]]))
            MPMusicPlayerController.systemMusicPlayer.play()
        }
        tableView.reloadData()
    }
}

extension AlarmSoundViewController {
    func refresh() {
        MPMediaLibrary.requestAuthorization({ (status ) in
            switch status {
            case .denied, .notDetermined, .restricted:
                let alert = UIAlertController(title:"Failed to load music.",
                                              message:"Please allow access to your music.",
                                              preferredStyle:.alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
                let confirm = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (_) in
                                self.isFailedToAccessMusic = true
                            })
                        }
                    }
                }
                alert.addAction(cancel)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        })
        if let items = MPMediaQuery.songs().items {
            self.items = items
        } else {
            self.items.removeAll()
        }
    }
}

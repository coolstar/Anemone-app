//
//  AltIconsViewController.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class AltIconsViewController: UITableViewController {
    private var iconAssignments: [[String: String]] = []
    private var appNames: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        iconAssignments = []
        if let rawOverrides = UserDefaults.standard.dictionary(forKey: "iconOverrides") as? [String: [String: String]] {
            for (bundleIdentifier, rawOverride) in rawOverrides {
                var override = rawOverride
                override["bundleID"] = bundleIdentifier
                iconAssignments.append(override)
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func resetAll(_: Any?) {
        let alert = UIAlertController(title: String(localizationKey: "Reset All Assignments"),
                                      message: String(localizationKey: "Are you sure you want to reset all alt icon assignments?"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localizationKey: "Yes"),
                                      style: .destructive,
                                      handler: { _ in
                                        UserDefaults.standard.removeObject(forKey: "iconOverrides")
                                        UserDefaults.standard.synchronize()
                                        self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: String(localizationKey: "No"),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AltIconsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        iconAssignments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AltIconListCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "AltIconListCell")
        
        let iconAssignment = iconAssignments[indexPath.row]
        
        guard let bundleID = iconAssignment["bundleID"] else {
            fatalError("bundleID missing")
        }
        
        cell.textLabel?.text = appNames[bundleID]
        cell.detailTextLabel?.text = iconAssignment["theme"]
        return cell
    }
}

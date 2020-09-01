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
    private var selectedBundleID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AltIconsViewController.reloadData),
                                               name: IconHelper.shared.altIconsChangedNotification,
                                               object: nil)
        self.actuallyReload(reloadUI: true)
    }
    
    func actuallyReload(reloadUI: Bool) {
        appNames = [:]
        for proxy in LSApplicationWorkspace.default().allInstalledApplications() {
            guard let bundleURL = proxy.bundleURL(),
                let plistData = try? Data(contentsOf: bundleURL.appendingPathComponent("Info.plist")),
                let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
                let bundleIdentifier = proxy.anemIdentifier() else {
                continue
            }
            
            var appName = proxy.localizedName()
            if appName?.isEmpty ?? true {
                appName = plist["CFBundleExecutable"] as? String
            }
            
            appNames[bundleIdentifier] = appName ?? ""
        }
        
        iconAssignments = []
        if let rawOverrides = UserDefaults.standard.dictionary(forKey: "iconOverrides") as? [String: [String: String]] {
            for (bundleIdentifier, rawOverride) in rawOverrides {
                var override = rawOverride
                override["bundleID"] = bundleIdentifier
                iconAssignments.append(override)
            }
        }
        
        if reloadUI {
            tableView.reloadData()
        }
    }
    
    @objc func reloadData() {
        self.actuallyReload(reloadUI: true)
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
                                        NotificationCenter.default.post(name: IconHelper.shared.altIconsChangedNotification, object: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AltIconListCell") ??
            UITableViewCell(style: .value1, reuseIdentifier: "AltIconListCell")
        
        let iconAssignment = iconAssignments[indexPath.row]
        
        guard let bundleID = iconAssignment["bundleID"] else {
            fatalError("bundleID missing")
        }
        
        cell.textLabel?.text = appNames[bundleID]
        
        if var theme = iconAssignment["theme"] {
            cell.imageView?.image = IconHelper.shared.getThemedIconForBundle(bundle: bundleID, identifier: theme)
            cell.imageView?.layer.cornerRadius = 10
            cell.imageView?.clipsToBounds = true
            
            if theme.hasSuffix(".theme") {
                theme.removeLast(6)
            }
            cell.detailTextLabel?.text = theme
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension AltIconsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let iconAssignment = iconAssignments[indexPath.row]
        guard let bundleID = iconAssignment["bundleID"] else {
            return
        }
        selectedBundleID = bundleID
        
        self.performSegue(withIdentifier: "altIconReplaceIcon", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let iconAssignment = iconAssignments[indexPath.row]
            guard let bundleID = iconAssignment["bundleID"] else {
                return
            }
            
            var iconAssignments = (UserDefaults.standard.dictionary(forKey: "iconOverrides") as? [String: [String: String]]) ?? [:]
            iconAssignments.removeValue(forKey: bundleID)
            UserDefaults.standard.set(iconAssignments, forKey: "iconOverrides")
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: IconHelper.shared.altIconsChangedNotification, object: nil)
            self.actuallyReload(reloadUI: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "altIconReplaceIcon" {
            if let navController = segue.destination as? UINavigationController {
                if let iconsController = navController.topViewController as? IconSelectionViewController {
                    iconsController.bundleID = selectedBundleID
                }
            }
        }
    }
}

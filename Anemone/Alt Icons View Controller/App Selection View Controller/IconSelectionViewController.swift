//
//  IconSelectionViewController.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class IconSelectionViewController: UICollectionViewController {
    public var bundleID: String = ""
    
    private var themeIcons: [[String: Any]] = []
    private var selectedTheme: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: "AppIconCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "IconSelectionCell")
        
        var themes: [String] = []
        if let packages = UserDefaults.standard.array(forKey: "packages") as? [[String: Any]] {
            for package in packages {
                if let packageThemes = package["themes"] as? [[String: Any]] {
                    for theme in packageThemes {
                        if let name = theme["name"] as? String,
                            (theme["enabled"] as? Bool) ?? false {
                            themes.append(name)
                        }
                    }
                }
            }
        }
        
        for theme in themes {
            if let image = IconHelper.shared.getThemedIconForBundle(bundle: bundleID, identifier: theme) {
                themeIcons.append([
                    "theme": theme,
                    "icon": image
                ])
            }
        }
        
        themeIcons.sort { i, j -> Bool in
            if let iTheme = i["theme"] as? String,
                let jTheme = j["theme"] as? String {
                return iTheme.caseInsensitiveCompare(jTheme) == .orderedAscending
            }
            return true
        }
    }
    
    @objc func save(_: Any?) {
        if UserDefaults.standard.bool(forKey: "altIconPrompt") != true {
            let alert = UIAlertController(title: String(localizationKey: "Alt Icon Saved"),
                                          message: String(localizationKey: "Alt Icon Saved. To apply the new assignments, go to the main Anemone panel and tap Apply."),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: String(localizationKey: "OK"), style: .default, handler: { _ in
                self.actuallySave()
                UserDefaults.standard.set(true, forKey: "altIconPrompt")
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.actuallySave()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func actuallySave() {
        var iconAssignments = (UserDefaults.standard.dictionary(forKey: "iconOverrides") as? [String: [String: String]]) ?? [:]
        iconAssignments[bundleID] = ["theme": selectedTheme]
        UserDefaults.standard.set(iconAssignments, forKey: "iconOverrides")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: IconHelper.shared.altIconsChangedNotification, object: nil)
    }
    
    @IBAction func dismiss(_: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension IconSelectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        themeIcons.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconSelectionCell", for: indexPath)
        if let iconCell = cell as? AppIconCollectionViewCell {
            let themeIcon = themeIcons[indexPath.row]
            
            iconCell.imageView.image = themeIcon["icon"] as? UIImage
            if var theme = themeIcon["theme"] as? String {
                if theme.hasSuffix(".theme") {
                    theme.removeLast(6)
                }
                iconCell.labelView.text = theme
            }
            
            iconCell.imageView.layer.cornerRadius = 12
            iconCell.imageView.clipsToBounds = true
        }
        return cell
    }
}

extension IconSelectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTheme = themeIcons[indexPath.row]
        guard let themeName = selectedTheme["theme"] as? String else {
            return
        }
        self.selectedTheme = themeName
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(IconSelectionViewController.save(_:)))
    }
}

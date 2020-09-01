//
//  IconSelectionViewController.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class IconSelectionViewController: UIViewController {
    public var bundleID: String = ""
    
    private var appIcons: [[String: Any]] = []
    private var themeIcons: [[String: Any]] = []
    private var selectedTheme: String = ""
    private var selectedName: String = ""
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var filterOption: UISegmentedControl!
    @IBOutlet private var themeSelector: UIBarButtonItem!
    @IBOutlet private var pickerView: UIPickerView!
    @IBOutlet private var pickerViewHeight: NSLayoutConstraint!
    
    private var showThemeIcons = false
    
    private var themes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: "AppIconCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "IconSelectionCell")
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
        themes.sort()
        
        for theme in themes {
            if let image = IconHelper.shared.getThemedIconForBundle(bundle: bundleID, identifier: theme) {
                appIcons.append([
                    "theme": theme,
                    "icon": image
                ])
            }
        }
        
        if themes.isEmpty {
            filterOption.isEnabled = false
        } else {
            selectedTheme = themes.first ?? ""
        }
        
        appIcons.sort { i, j -> Bool in
            if let iTheme = i["theme"] as? String,
                let jTheme = j["theme"] as? String {
                return iTheme.caseInsensitiveCompare(jTheme) == .orderedAscending
            }
            return true
        }
    }
    
    private func reloadData() {
        if showThemeIcons {
            themeIcons = []
            
            let iconBundlesDir = PackageListManager.shared.prefixDir()
                .appendingPathComponent(selectedTheme).appendingPathComponent("IconBundles")
            
            if let contents = try? FileManager.default.contentsOfDirectory(at: iconBundlesDir,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            {
                let iconNamesRaw = contents.filter { $0.pathExtension.lowercased() == "png" }
                    .map { $0.deletingPathExtension().lastPathComponent
                        .deletingSuffix("~ipad").deletingSuffix("@3x")
                        .deletingSuffix("@2x").deletingSuffix("~ipad")
                        .deletingSuffix("-large") }
                let iconNames = Array(Set(iconNamesRaw)).sorted()
                
                for iconName in iconNames {
                    if let image = IconHelper.shared.getThemedIconForBundle(bundle: iconName, identifier: selectedTheme) {
                        themeIcons.append([
                            "theme": selectedTheme,
                            "icon": image,
                            "name": iconName
                        ])
                    }
                }
            }
        }
        collectionView.reloadData()
        self.navigationItem.rightBarButtonItem = nil
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
        if selectedName.isEmpty {
            iconAssignments[bundleID] = ["theme": selectedTheme]
        } else {
            iconAssignments[bundleID] = ["theme": selectedTheme, "name": selectedName]
        }
        UserDefaults.standard.set(iconAssignments, forKey: "iconOverrides")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: IconHelper.shared.altIconsChangedNotification, object: nil)
    }
    
    @IBAction func dismiss(_: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterChanged(_: Any?) {
        showThemeIcons = (filterOption.selectedSegmentIndex == 1)
        themeSelector.isEnabled = showThemeIcons
        self.reloadData()
    }
    
    @IBAction func toggleThemeSelector(_: Any?) {
        UIView.animate(withDuration: 0.25) {
            if self.filterOption.isEnabled {
                self.themeSelector.title = String(localizationKey: "Done")
                self.pickerView.alpha = 1
                self.pickerViewHeight.isActive = false
            } else {
                self.themeSelector.title = String(localizationKey: "Themes")
                self.pickerView.alpha = 0
                self.pickerViewHeight.isActive = true
            }
            self.view.setNeedsUpdateConstraints()
            self.view.setNeedsLayout()
        }
        filterOption.isEnabled = !filterOption.isEnabled
    }
}

extension IconSelectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showThemeIcons ? themeIcons.count : appIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconSelectionCell", for: indexPath)
        if let iconCell = cell as? AppIconCollectionViewCell {
            if showThemeIcons {
                let themeIcon = themeIcons[indexPath.row]
                iconCell.imageView.image = themeIcon["icon"] as? UIImage
                iconCell.labelView.text = ""
            } else {
                let themeIcon = appIcons[indexPath.row]
                
                iconCell.imageView.image = themeIcon["icon"] as? UIImage
                if var theme = themeIcon["theme"] as? String {
                    if theme.hasSuffix(".theme") {
                        theme.removeLast(6)
                    }
                    iconCell.labelView.text = theme
                }
            }
            
            iconCell.imageView.layer.cornerRadius = 12
            iconCell.imageView.clipsToBounds = true
        }
        return cell
    }
}

extension IconSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showThemeIcons {
            let selectedTheme = themeIcons[indexPath.row]
            guard let themeName = selectedTheme["theme"] as? String,
                let iconName = selectedTheme["name"] as? String else {
                return
            }
            self.selectedTheme = themeName
            self.selectedName = iconName
        } else {
            let selectedTheme = appIcons[indexPath.row]
            guard let themeName = selectedTheme["theme"] as? String else {
                return
            }
            self.selectedTheme = themeName
            self.selectedName = ""
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(IconSelectionViewController.save(_:)))
    }
}

extension IconSelectionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        themes.count
    }
}

extension IconSelectionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        themes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTheme = themes[row]
        self.reloadData()
    }
}

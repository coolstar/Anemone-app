//
//  AppSelectionViewController.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class AppSelectionViewController: UICollectionViewController {
    private var apps: [[String: Any]] = []
    private var cachedIcons: [String: UIImage] = [:]
    private var selectedBundleID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "AppIconCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "AppSelectionCell")
        
        apps = []
        for proxy in LSApplicationWorkspace.default().allInstalledApplications() {
            guard let bundleURL = proxy.bundleURL(),
                let plistData = try? Data(contentsOf: bundleURL.appendingPathComponent("Info.plist")),
                let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
                let bundleID = proxy.anemIdentifier() else {
                continue
            }
            if let tags = plist["SBAppTags"] as? [String],
                tags.contains("hidden") {
                continue
            }
            if let visibility = plist["SBIconVisibilityDefaultVisible"] as? Bool,
                !visibility {
                continue
            }
            
            let isiPad = UIDevice.current.userInterfaceIdiom == .pad
            var icon = IconHelper.shared.getHomeScreenIconForApp(app: proxy, isiPad: isiPad, getThemed: true)
            if icon == nil {
                icon = IconHelper.shared.getHomeScreenIconForApp(app: proxy, isiPad: isiPad, getThemed: false)
            }
            icon = icon?._applicationIconImage(forFormat: 2, precomposed: (plist["UIPrerenderedIcon"] as? Bool) ?? false, scale: 2)
            guard let appIcon = icon else {
                continue
            }
            
            var iconLabelText = proxy.localizedName()
            if iconLabelText?.isEmpty ?? true {
                iconLabelText = plist["CFBundleExecutable"] as? String
            }
            
            apps.append([
                "bundleIdentifier": bundleID,
                "icon": appIcon,
                "appName": iconLabelText ?? ""
            ])
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func dismiss(_: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AppSelectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        apps.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppSelectionCell", for: indexPath)
        if let appCell = cell as? AppIconCollectionViewCell {
            let app = apps[indexPath.row]
                       
            appCell.imageView.image = app["icon"] as? UIImage
            appCell.labelView.text = app["appName"] as? String
        }
        
        return cell
    }
}

extension AppSelectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        selectedBundleID = (apps[indexPath.row]["bundleIdentifier"] as? String) ?? ""
        self.performSegue(withIdentifier: "altIconAddIcon", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let iconSelectionController = segue.destination as? IconSelectionViewController {
            iconSelectionController.bundleID = selectedBundleID
        }
    }
}

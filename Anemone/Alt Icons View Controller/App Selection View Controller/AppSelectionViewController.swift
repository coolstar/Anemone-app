//
//  AppSelectionViewController.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class AppSelectionViewController: UICollectionViewController {
    private var apps: [LSApplicationProxy] = []
    private var selectedBundleID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "AppIconCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "AppSelectionCell")
        
        apps = []
        for proxy in LSApplicationWorkspace.default().allInstalledApplications() {
            guard let bundleURL = proxy.bundleURL(),
                let plistData = try? Data(contentsOf: bundleURL.appendingPathComponent("Info.plist")),
                let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] else {
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
            apps.append(proxy)
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
            guard let bundleURL = app.bundleURL(),
                let plistData = try? Data(contentsOf: bundleURL.appendingPathComponent("Info.plist")),
                let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] else {
                return cell
            }
            
            let isiPad = UIDevice.current.userInterfaceIdiom == .pad
            var icon = IconHelper.shared.getHomeScreenIconForApp(app: app, isiPad: isiPad, getThemed: true)
            if icon == nil {
                icon = IconHelper.shared.getHomeScreenIconForApp(app: app, isiPad: isiPad, getThemed: false)
            }
            icon = icon?._applicationIconImage(forFormat: 2, precomposed: (plist["UIPrerenderedIcon"] as? Bool) ?? false, scale: 2)
            appCell.imageView.image = icon
            
            var iconLabelText = app.localizedName()
            if iconLabelText?.isEmpty ?? true {
                iconLabelText = plist["CFBundleExecutable"] as? String
            }
            appCell.labelView.text = iconLabelText
        }
        
        return cell
    }
}

extension AppSelectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        selectedBundleID = apps[indexPath.row].anemIdentifier() ?? ""
        
        self.performSegue(withIdentifier: "altIconAddIcon", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let iconSelectionController = segue.destination as? IconSelectionViewController {
            iconSelectionController.bundleID = selectedBundleID
        }
    }
}

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
    
    func getThemedIconForBundle(bundle: String, identifier: String) -> UIImage? {
        let themesDir = PackageListManager.shared.prefixDir().path
        
        let ibLargeThemePath = String(format: "%@/%@/IconBundles/%@-large.png", themesDir, identifier, bundle)
        var icon = UIImage(contentsOfFile: ibLargeThemePath)
        if icon != nil {
            return icon
        }
        
        let ibThemePath = String(format: "%@/%@/IconBundles/%@.png", themesDir, identifier, bundle)
        icon = UIImage(contentsOfFile: ibThemePath)
        if icon != nil {
            return icon
        }
        return nil
    }
    
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
            if let image = getThemedIconForBundle(bundle: bundleID, identifier: theme) {
                themeIcons.append([
                    "theme": theme,
                    "icon": image
                ])
            }
        }
    }
    
    @objc func save(_: Any?){
        
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(IconSelectionViewController.save(_:)))
    }
}

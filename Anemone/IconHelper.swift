//
//  IconHelper.swift
//  Anemone
//
//  Created by CoolStar on 8/31/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

class IconHelper {
    public static let shared = IconHelper()
    
    public let altIconsChangedNotification = Notification.Name("SileoAltIconsChanged")
    public func getHomeScreenIconForApp(app: LSApplicationProxy, isiPad: Bool, getThemed: Bool) -> UIImage? {
        let iconsDictionary = app.iconsDictionary()
        let bundle = Bundle(url: app.bundleURL()!)
        
        var variant: Int32 = 15
        if isiPad {
            variant = 24
        } else {
            if UIScreen.main.scale == 3 {
                variant = 32
            }
        }
        
        let options: Int32 = 0
        
        return getIconForBundle(bundle, iconsDictionary, variant, options, 2.0, getThemed)
    }
    
    public func getThemedIconForBundle(bundle: String, identifier: String) -> UIImage? {
        var bundleIdentifier = bundle
        let themesDir = PackageListManager.shared.prefixDir().path
        
        if bundleIdentifier == "com.anemoneteam.anemone" {
            bundleIdentifier = "com.anemonetheming.anemone"
        }

        if bundleIdentifier == "org.coolstar.electra1141" {
            bundleIdentifier = "org.coolstar.electra1131"
        }
        
        let ibLargeThemePath = String(format: "%@/%@/IconBundles/%@-large.png", themesDir, identifier, bundleIdentifier)
        var icon = UIImage(contentsOfFile: ibLargeThemePath)
        if icon != nil {
            return icon
        }
        
        let ibThemePath = String(format: "%@/%@/IconBundles/%@.png", themesDir, identifier, bundleIdentifier)
        icon = UIImage(contentsOfFile: ibThemePath)
        if icon != nil {
            return icon
        }
        return nil
    }
}

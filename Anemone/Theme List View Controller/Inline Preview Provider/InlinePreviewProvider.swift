//
//  InlinePreviewProvider.swift
//  Anemone
//
//  Created by CoolStar on 10/29/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

import Foundation
import UIKit

class InlinePreviewProvider {
    static let shared = InlinePreviewProvider()
    
    var previewViews: [String: UIScrollView] = [:]
    
    func getThemedIconForBundle(bundle: String, themeCategoryNode: ThemeCategoryNode?) -> String? {
        guard let themes = themeCategoryNode?.themes else {
            return nil
        }
        
        let themesDir = PackageListManager.shared.prefixDir().path
        
        for themeNode in themes {
            let identifier = themeNode.identifier
            
            let ibLargeThemePath = String(format: "%@/%@/IconBundles/%@-large.png", themesDir, identifier, bundle)
            var icon = UIImage(contentsOfFile: ibLargeThemePath)
            if icon != nil {
                return ibLargeThemePath
            }
            
            let ibThemePath = String(format: "%@/%@/IconBundles/%@.png", themesDir, identifier, bundle)
            icon  = UIImage(contentsOfFile: ibThemePath)
            if icon != nil {
                return ibThemePath
            }
        }
        return nil
    }
    
    func previewViewForTheme(themeCategoryNode: ThemeCategoryNode?) -> UIScrollView {
        guard let themeIdentifier = themeCategoryNode?.identifier else {
            return UIScrollView()
        }
        if previewViews[themeIdentifier] != nil {
            return previewViews[themeIdentifier]!
        }
        
        let scrollPreviews = UIScrollView()
        
        let bundleIds = ["com.apple.MobileSMS", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.weather",
                         "com.apple.Maps", "com.apple.videos", "com.apple.mobilenotes", "com.apple.reminders",
                         "com.apple.stocks", "com.apple.news", "com.apple.MobileStore",
                         "com.apple.AppStore", "com.apple.iBooks", "com.apple.Health", "com.apple.Passbook",
                         "com.apple.Preferences"].shuffled()
        var x = 0
        for bundle in bundleIds {
            guard let icon = getThemedIconForBundle(bundle: bundle, themeCategoryNode: themeCategoryNode) else {
                continue
            }
            
            let iconView = UIImageView(frame: CGRect(x: x, y: 0, width: 32, height: 32))
            iconView.image = UIImage(contentsOfFile: icon)
            iconView.clipsToBounds = true
            iconView.layer.cornerRadius = 5
            scrollPreviews.addSubview(iconView)
            
            x+=40
        }
        scrollPreviews.contentSize = CGSize(width: x, height: 40)
        scrollPreviews.showsVerticalScrollIndicator = false
        scrollPreviews.showsHorizontalScrollIndicator = false
        
        previewViews[themeIdentifier] = scrollPreviews
        return scrollPreviews
    }
}

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
    
    var previewViews : Dictionary<String, UIScrollView> = [:]
    
    func getThemedIconForBundle(bundle: String, themeCategoryNode : ThemeCategoryNode?) -> String? {
        let themesDir : String = PackageListManager.sharedInstance().prefixDir()
        
        for themeNode in (themeCategoryNode?.themes)! {
            let identifier : String = themeNode.identifier
            
            let ibLargeThemePath : String = String(format: "%@/%@/IconBundles/%@-large.png", themesDir, identifier, bundle)
            var icon : UIImage? = UIImage(contentsOfFile: ibLargeThemePath)
            if (icon != nil) {
                return ibLargeThemePath
            }
            
            let ibThemePath : String = String(format: "%@/%@/IconBundles/%@.png", themesDir, identifier, bundle)
            icon  = UIImage(contentsOfFile: ibThemePath)
            if (icon != nil) {
                return ibThemePath
            }
        }
        return nil
    }
    
    func previewViewForTheme(themeCategoryNode: ThemeCategoryNode?) -> UIScrollView {
        if (previewViews[(themeCategoryNode?.identifier)!] != nil){
            return previewViews[(themeCategoryNode?.identifier)!]!
        }
        
        let scrollPreviews : UIScrollView = UIScrollView()
        
        let bundleIds = ["com.apple.MobileSMS", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.weather", "com.apple.Maps", "com.apple.videos", "com.apple.mobilenotes", "com.apple.reminders", "com.apple.stocks", "com.apple.news", "com.apple.MobileStore", "com.apple.AppStore", "com.apple.iBooks", "com.apple.Health", "com.apple.Passbook", "com.apple.Preferences"]
        var x = 0
        for bundle in bundleIds {
            let icon : String? = getThemedIconForBundle(bundle: bundle, themeCategoryNode: themeCategoryNode)
            if (icon == nil){
                continue
            }
            
            let iconView : UIImageView = UIImageView(frame: CGRect(x: x, y: 0, width: 32, height: 32))
            iconView.image = UIImage(contentsOfFile: icon!)
            iconView.clipsToBounds = true
            iconView.layer.cornerRadius = 5
            scrollPreviews.addSubview(iconView)
            
            x+=40
        }
        scrollPreviews.contentSize = CGSize(width: x, height: 40)
        scrollPreviews.showsVerticalScrollIndicator = false
        scrollPreviews.showsHorizontalScrollIndicator = false
        
        previewViews[(themeCategoryNode?.identifier)!] = scrollPreviews
        return scrollPreviews
    }
}

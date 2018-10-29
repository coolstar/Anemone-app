//
//  ANEMListCategoryTableViewCell.swift
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

import UIKit

class ANEMListCategoryTableViewCell: ANEMListThemeTableViewCell {
    @IBOutlet var scrollPreviews : UIScrollView?
    var themeCategoryNode : ThemeCategoryNode?
    
    func getThemedIconForBundle(bundle: String) -> String? {
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
    
    func reloadTheme(){
        scrollPreviews?.subviews.forEach({ (view) in
            view.removeFromSuperview()
        })
        
        let bundleIds = ["com.apple.MobileSMS", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.weather"]
        var x = 0
        for bundle in bundleIds {
            let icon : String? = getThemedIconForBundle(bundle: bundle)
            if (icon == nil){
                continue
            }
            
            let iconView : UIImageView = UIImageView(frame: CGRect(x: x, y: 0, width: 32, height: 32))
            iconView.image = UIImage(contentsOfFile: icon!)
            iconView.clipsToBounds = true
            iconView.layer.cornerRadius = 5
            scrollPreviews?.addSubview(iconView)
            
            x+=40
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

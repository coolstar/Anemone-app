//
//  ANEMListCategoryTableViewCell.swift
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

import UIKit

class ANEMListCategoryTableViewCell: ANEMListThemeTableViewCell {
    @IBOutlet var scrollPreviews : UIView?
    var themeCategoryNode : ThemeCategoryNode?
    
    func reloadTheme(){
        let scrollPreview : UIScrollView = InlinePreviewProvider.shared.previewViewForTheme(themeCategoryNode: themeCategoryNode)
        scrollPreview.removeFromSuperview()
        
        scrollPreview.autoresizingMask = AutoresizingMask(rawValue:AutoresizingMask.flexibleWidth.rawValue | AutoresizingMask.flexibleHeight.rawValue)
        scrollPreview.frame = (scrollPreviews?.bounds)!
        scrollPreviews?.addSubview(scrollPreview)
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

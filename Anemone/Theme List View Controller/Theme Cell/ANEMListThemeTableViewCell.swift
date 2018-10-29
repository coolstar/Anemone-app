//
//  ANEMListThemeTableViewCell.swift
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

import UIKit

class ANEMListThemeTableViewCell: UITableViewCell {
    @IBOutlet var themeLabel : UILabel?
    @IBOutlet var enableButton : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

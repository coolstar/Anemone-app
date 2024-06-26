//
//  ThemeCategoryNode.swift
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

class ThemeCategoryNode: ThemeNode {
    override var isExpandable: Bool {
        true
    }
    
    var themes: [ThemeNode] = []
    
    override var isEnabled: Bool {
        var enabled = false
        themes.forEach { theme in
            if theme.isEnabled {
                enabled = true
            }
        }
        return enabled
    }
}

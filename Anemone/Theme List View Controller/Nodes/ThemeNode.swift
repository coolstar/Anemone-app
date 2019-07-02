//
//  ThemeNode.swift
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

class ThemeNode : TreeNodeProtocol {
    var identifier = ""
    var humanReadable = ""
    var isExpandable : Bool {
        return false
    }
    
    var enabled = false
    var isEnabled : Bool {
        return enabled
    }
}

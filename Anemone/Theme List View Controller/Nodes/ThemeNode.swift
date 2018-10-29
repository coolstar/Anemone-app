//
//  ThemeNode.swift
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

import LNZTreeView

class ThemeNode: NSObject, TreeNodeProtocol {
    var identifier: String = ""
    var humanReadable : String = ""
    var isExpandable: Bool {
        return false
    }
    
    var enabled : Bool = false
    var isEnabled : Bool {
        return enabled
    }
}

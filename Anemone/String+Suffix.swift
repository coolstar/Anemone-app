//
//  String+Suffix.swift
//  Anemone
//
//  Created by CoolStar on 9/1/20.
//  Copyright © 2020 CoolStar. All rights reserved.
//

import Foundation

extension String {
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

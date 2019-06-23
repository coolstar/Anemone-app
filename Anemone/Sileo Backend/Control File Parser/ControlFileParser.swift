//
//  ControlFileParser.swift
//  Sileo
//
//  Created by CoolStar on 6/22/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

class ControlFileParser: NSObject {
    class func dictionary(controlFile:String, isReleaseFile:Bool) -> Dictionary<String, String> {
        guard let controlData = controlFile.data(using: .utf8) else {
            return Dictionary()
        }
        return dictionary(controlData: controlData, isReleaseFile: isReleaseFile)
    }
    
    class func dictionary(controlData:Data, isReleaseFile:Bool) -> Dictionary<String, String> {
        let separator = "\n".data(using: .utf8)!
        let keyValueSeparator = ":".data(using: .utf8)!
        let space = " ".data(using: .utf8)!
        
        var dictionary = Dictionary<String, String>()
        var lastMultilineKey = "";
        
        var index = 0;
        while (index < controlData.count) {
            let range = controlData.range(of: separator, options:[], in: index..<controlData.count)
            var newIndex = 0
            if ((range) != nil){
                newIndex = range!.lowerBound + separator.count
            } else {
                newIndex = controlData.count
            }
            
            let subRange = index..<newIndex
            let lineData = controlData.subdata(in: subRange)
            
            let separatorRange = lineData.range(of: keyValueSeparator, options:[], in: 0..<lineData.count) ?? 0..<0
            if (separatorRange.upperBound == 0){
                if (lastMultilineKey == ""){
                    index = newIndex
                    continue
                }
            }
            var rawKey : Data = "".data(using: .utf8)!
            if (separatorRange.upperBound != 0) {
                rawKey = lineData.subdata(in: 0..<separatorRange.lowerBound)
            }
            guard (rawKey.count != 0 && rawKey.range(of: space, options:[], in: 0..<rawKey.count) == nil) else {
                if (lastMultilineKey != ""){
                    let line = String.init(data: lineData, encoding: .utf8) ?? ""
                    let newValue = dictionary[lastMultilineKey]?.appendingFormat("\n%@", line.trimmingLeadingWhitespace())
                    dictionary[lastMultilineKey] = newValue
                }
                index = newIndex
                continue
            }
            let key = String.init(data: rawKey, encoding: .utf8)?.lowercased()
            let rawValue = lineData.subdata(in: separatorRange.lowerBound + 1 ..< lineData.count)
            var multiLineKeys = ["description"]
            if (isReleaseFile){
                multiLineKeys = ["description", "md5sum", "sha1", "sha256", "sha512"]
            }
            if (key != nil && multiLineKeys.contains(key!)){
                lastMultilineKey = key!
            } else {
                lastMultilineKey = ""
            }
            
            var rawValueArr = [UInt8](rawValue)
            if (rawValueArr.count != 0){
                let spaceChar = Array(" ".utf8)[0]
                let newLineChar = Array("\n".utf8)[0]
                while (rawValueArr[0] == spaceChar){
                    rawValueArr.removeFirst()
                }
                while (rawValueArr.last == spaceChar || rawValueArr.last == newLineChar){
                    rawValueArr.removeLast()
                }
            }
            
            let value : String = String(bytes: rawValueArr, encoding: .utf8) ?? ""
            dictionary[key ?? ""] = value
            
            index = newIndex
        }
        return dictionary
    }
    
    class func authorName(string:String) -> String {
        guard let emailIndex = string.firstIndex(of: "<") else {
            return string.trimmingCharacters(in: .whitespaces)
        }
        return string[..<emailIndex].trimmingCharacters(in: .whitespaces)
    }
    
    class func authorEmail(string:String) -> String? {
        guard let emailIndex = string.firstIndex(of: "<") else {
            return nil
        }
        let email = string[emailIndex...]
        guard let emailLastIndex = email.firstIndex(of: ">") else {
            return nil
        }
        return String(email[..<emailLastIndex])
    }
}

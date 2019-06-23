//
//  PackageListManager.swift
//  Anemone
//
//  Created by CoolStar on 6/23/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

@objc class PackageListManager: NSObject {
    static let shared = PackageListManager()
    
    func package(dictionary:Dictionary<String,String>) -> Package {
        let package = Package()
        package.package = dictionary["package"]
        package.name = dictionary["name"]
        if (package.name == nil){
            package.name = package.package
        }
        package.version = dictionary["version"]
        package.architecture = dictionary["architecture"]
        package.maintainer = dictionary["maintainer"]
        if (package.maintainer != nil){
            if (dictionary["author"] != nil){
                package.author = dictionary["author"]
            } else {
                package.author = dictionary["maintainer"]
            }
        }
        package.rawControl = dictionary
        return package
    }
    
    func dpkgDir() -> URL {
#if targetEnvironment(simulator)
        return Bundle.main.bundleURL.appendingPathComponent("Test Data")
#else
        return URL(fileURLWithPath: "/var/lib/dpkg")
#endif
    }
    
    func packagesList() -> Dictionary<String, Package> {
        let packagesFile = self.dpkgDir().appendingPathComponent("status").resolvingSymlinksInPath()
        
        var packagesList = Dictionary<String, Package>()
        
        do {
            let rawPackagesData = try Data.init(contentsOf: packagesFile)
            
            var index = 0
            var separator = "\n\n".data(using: .utf8)!
            
            guard let firstSeparator = rawPackagesData.range(of: "\n".data(using: .utf8)!, options:[], in:0..<rawPackagesData.count) else {
                return packagesList
            }
            if (firstSeparator.lowerBound != 0){
                let subdata = rawPackagesData.subdata(in: firstSeparator.lowerBound-1..<firstSeparator.lowerBound)
                let character = subdata.first
                if (character == 13){ // \r
                    //Found windows line endings
                    separator = "\r\n\r\n".data(using: .utf8)!
                }
            }
            
            var tempDictionary = Dictionary<String, Any>()
            while (index < rawPackagesData.count){
                let range = rawPackagesData.range(of: separator, options:[], in:index..<rawPackagesData.count)
                var newIndex = 0
                if (range == nil){
                    newIndex = rawPackagesData.count
                } else {
                    newIndex = range!.lowerBound + separator.count
                }
                
                let subRange = index..<newIndex
                let packageData = rawPackagesData.subdata(in: subRange)
                
                index = newIndex
                
                guard var rawPackage = try? ControlFileParser.dictionary(controlData: packageData, isReleaseFile: false) else {
                    continue
                }
                guard rawPackage["package"] != nil else {
                    continue
                }
                if (rawPackage["package"] == ""){
                    continue
                }
                if ((rawPackage["package"]?.hasPrefix("gsc."))!) {
                    continue
                }
                if ((rawPackage["package"]?.hasPrefix("cy+"))!) {
                    continue
                }
                
                let package = self.package(dictionary: rawPackage)
                var wantInfo : pkgwant = PKG_WANT_INSTALL
                var eFlag : pkgeflag = PKG_EFLAG_OK
                var pkgStatus : pkgstatus = PKG_STAT_INSTALLED
                
                let statusValid = DpkgWrapper.getValuesForStatusField(package.rawControl["status"], wantInfo: &wantInfo, eFlag: &eFlag, status: &pkgStatus)
                if (!statusValid){
                    continue
                }
                
                package.wantInfo = wantInfo
                package.eFlag = eFlag
                package.status = pkgStatus
                
                if (package.eFlag == PKG_EFLAG_OK){
                    if (package.status == PKG_STAT_NOTINSTALLED || package.status == PKG_STAT_CONFIGFILES){
                        continue
                    }
                }
                
                packagesList[package.package!] = package
            }
            tempDictionary.removeAll()
        } catch let error {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
        
        return packagesList
    }
    
    func prefixDir() -> URL {
#if targetEnvironment(simulator)
        return Bundle.main.bundleURL.appendingPathComponent("Test Themes")
#else
        return URL(fileURLWithPath: "/Library/Themes")
#endif
    }
    
    func scanForThemes() -> Dictionary<String, Array<String>> {
#if targetEnvironment(simulator)
        let themesDirContents = ["Amury Alt Apple Icons.theme", "Amury Alt Icons.theme",
                                  "Amury Apple Music Icon.theme", "Amury Control Center.theme",
                                   "Amury Icons.theme", "Amury Interface.theme",
                                    "Amury Keyboard Sounds.theme", "Amury Legacy Icons.theme",
                                     "Amury Messages.theme", "Felicity iOS 11.theme",
                                      "Felicity.theme", "iOS 7-10 icons.theme", "iOS 8 Music Icon.theme "]
#else
        let themesDirContents = FileManager.default.contentsOfDirectory(atPath: self.prefixDir().path)
#endif
        var themesFolders = Array<String>()
        let prefixURL = URL(fileURLWithPath: "/Library/Themes")
        for folder in themesDirContents {
            let fullPath = prefixURL.appendingPathComponent(folder).path
            themesFolders.append(fullPath)
        }
        
        var themeIdentifiers = Dictionary<String, Array<String>>()
        
        let contentsFilesURL = self.dpkgDir().appendingPathComponent("info").resolvingSymlinksInPath()
        do {
            let contentsFiles = try FileManager.default.contentsOfDirectory(atPath: contentsFilesURL.path)
            
            for packageFile in contentsFiles {
                if (!packageFile.hasSuffix(".list")){
                    continue
                }
                let fullURL = contentsFilesURL.appendingPathComponent(packageFile)
                do {
                    let contents = try String.init(contentsOf: fullURL, encoding: .utf8)
                    
                    let files = contents.components(separatedBy: CharacterSet(charactersIn: "\n"))
                    
                    var itemsToRemove = Array<String>()
                    
                    for themePath in themesFolders {
                        if files.contains(themePath){
                            let packageID : String = (URL(string: packageFile)?.deletingPathExtension().path)!
                            var paths = themeIdentifiers[packageID]
                            if (paths == nil){
                                paths = Array()
                                themeIdentifiers[packageID] = paths
                            }
                            paths?.append((themePath as NSString).lastPathComponent)
                            itemsToRemove.append(themePath)
                            themeIdentifiers[packageID] = paths
                        }
                    }
                    for item in itemsToRemove {
                        themesFolders.removeAll { (iter) -> Bool in
                            item == iter
                        }
                    }
                } catch let error {
#if DEBUG
                    print(error.localizedDescription)
#endif
                    continue
                }
            }
            
            for themePath in themesFolders {
                let packageId = "com.anemonetheming.unknown"
                var paths = themeIdentifiers[packageId]
                if (paths == nil){
                    paths = Array()
                    themeIdentifiers[packageId] = paths
                }
                paths?.append(themePath)
            }
        } catch let error {
#if DEBUG
            print(error.localizedDescription)
#endif
        }
        return themeIdentifiers
    }
}
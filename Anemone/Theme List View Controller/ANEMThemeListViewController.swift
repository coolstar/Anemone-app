//
//  ANEMThemeListViewController.swift
//  
//
//  Created by CoolStar on 10/28/18.
//

import UIKit

class ANEMThemeListViewController: UIViewController {
    
    @IBOutlet var treeView: LNZTreeView?
    var themeSections: [ThemeCategoryNode] = []
    var previewIsStale = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewIsStale = false
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ANEMThemeListViewController.markStale),
                                               name: IconHelper.shared.altIconsChangedNotification,
                                               object: nil)
        
        UserDefaults.standard.set(UIDevice.current.userInterfaceIdiom.rawValue, forKey: "userInterfaceIdiom")
        UserDefaults.standard.set(UIScreen.main.scale, forKey: "displayScale")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(ANEMThemeListViewController.toggleEditing))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localizationKey: "Preview"),
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(ANEMThemeListViewController.applyThemes))
        
        treeView?.register(UINib(nibName: "ANEMListCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "themeSections")
        treeView?.register(UINib(nibName: "ANEMListThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "themeRows")
        
        let themesFolderContents = PackageListManager.shared.scanForThemes()
        
        let packages = PackageListManager.shared.packagesList()
        
        let rawSettings = UserDefaults.standard.array(forKey: "packages") as? [[String: Any]]
        
        var rawOrderedPackages: [String] = []
        var rawHashedPackages: [String: [[String: Any]]] = [:]
        rawSettings?.forEach { rawPackage in
            guard let identifier = rawPackage["identifier"] as? String else {
                return
            }
            rawOrderedPackages.append(identifier)
            
            rawHashedPackages[identifier] = rawPackage["themes"] as? [[String: Any]]
        }
        
        var sectionsDict: [String: ThemeCategoryNode] = [:]
        themesFolderContents.forEach { arg0 in
            let (themeIdentifier, themeFolders) = arg0
            
            let rawThemes = rawHashedPackages[themeIdentifier]
            var orderedThemes: [String] = []
            var hashedThemes: [String: Bool] = [:]
            rawThemes?.forEach({ rawTheme in
                guard let rawThemeName = rawTheme["name"] as? String else {
                    return
                }
                guard let rawThemeEnabled = rawTheme["enabled"] as? Bool else {
                    return
                }
                if themeFolders.contains(rawThemeName) {
                    orderedThemes.append(rawThemeName)
                    hashedThemes[rawThemeName] = rawThemeEnabled
                }
            })
            
            let node = ThemeCategoryNode()
            
            let package = packages[themeIdentifier]
            
            node.identifier = themeIdentifier
            node.humanReadable = package?.name ?? themeIdentifier
            if themeIdentifier == "com.anemonetheming.unknown" {
                node.humanReadable = String(localizationKey: "Miscellaneous")
            }
            
            var hashedNodeThemes: [String: ThemeNode] = [:]
            
            themeFolders.forEach({ folder in
                let themeNode = ThemeNode()
                themeNode.identifier = folder
                
                let folderStr = folder as NSString
                
                themeNode.humanReadable = folderStr.deletingPathExtension
                themeNode.enabled = hashedThemes[folder] ?? false
                hashedNodeThemes[folder] = themeNode
                
                if !orderedThemes.contains(folder) {
                    orderedThemes.append(folder)
                }
            })
            
            orderedThemes.forEach({ folder in
                node.themes.append(hashedNodeThemes[folder]!)
            })
            
            sectionsDict[themeIdentifier] = node
            if !rawOrderedPackages.contains(themeIdentifier) {
                rawOrderedPackages.append(themeIdentifier)
            }
        }
        
        rawOrderedPackages.forEach { identifier in
            guard let section = sectionsDict[identifier] else {
                return
            }
            themeSections.append(section)
        }

        // Do any additional setup after loading the view.
    }

    @objc func toggleEditing() {
        let editing = treeView?.isEditing ?? false
        treeView?.setEditing(!editing, animated: true)
        if !editing {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                    target: self,
                                                                    action: #selector(ANEMThemeListViewController.toggleEditing))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                    target: self,
                                                                    action: #selector(ANEMThemeListViewController.toggleEditing))
        }
    }
    
    @objc func markStale() {
        writeSettings()
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        self.viewDidLayoutSubviews()
    }
    
    func writeSettings() {
        var settings: [[String: Any]] = []
        themeSections.forEach { themeFolder in
            var themePackage: [String: Any] = [:]
            themePackage["identifier"] = themeFolder.identifier
            
            var themes: [[String: Any]] = []
            themeFolder.themes.forEach({ themeNode in
                var theme: [String: Any] = [:]
                theme["name"] = themeNode.identifier
                theme["enabled"] = themeNode.enabled
                themes.append(theme)
            })
            themePackage["themes"] = themes
            settings.append(themePackage)
        }
        UserDefaults.standard.set(settings, forKey: "packages")
        
        var settingsPacked: [String] = []
        settings.forEach { themePackage in
            guard let themes = themePackage["themes"] as? [[String: Any]] else {
                return
            }
            themes.forEach({ theme in
                guard let themeEnabled = theme["enabled"] as? Bool else {
                    return
                }
                guard let themeName = theme["name"] as? String else {
                    return
                }
                if themeEnabled == true {
                    settingsPacked.append(themeName)
                }
            })
        }
        UserDefaults.standard.set(settingsPacked, forKey: "settingsPacked")
        
        UserDefaults.standard.synchronize()
        previewIsStale = true
        self.viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.splitViewController?.isCollapsed)! {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localizationKey: "Preview"),
                                                                     style: .done,
                                                                     target: self,
                                                                     action: #selector(ANEMThemeListViewController.applyThemes))
        } else {
            if previewIsStale {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localizationKey: "Refresh Preview"),
                                                                         style: .done,
                                                                         target: self,
                                                                         action: #selector(ANEMThemeListViewController.applyThemes))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localizationKey: "Apply"),
                                                                         style: .done,
                                                                         target: self,
                                                                         action: #selector(ANEMThemeListViewController.applyThemes))
            }
        }
    }
    
    @objc func applyThemes() {
        if (self.splitViewController?.isCollapsed)! {
            let previewController = ANEMPreviewController()
            let navController = UINavigationController(rootViewController: previewController)
            self.present(navController, animated: true) {
                
            }
        } else {
            guard let previewController = self.splitViewController?.viewControllers[1] as? ANEMPreviewController else {
                return
            }
            if previewIsStale {
                previewController.refreshTheme()
                previewIsStale = false
                self.viewDidLayoutSubviews()
            } else {
                previewController.applyThemes()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ANEMThemeListViewController: LNZTreeViewDataSource {
    func numberOfSections(in treeView: LNZTreeView) -> Int {
        1
    }
    
    func treeView(_ treeView: LNZTreeView, numberOfRowsInSection section: Int, forParentNode parentNode: TreeNodeProtocol?) -> Int {
        guard let parent = parentNode as? ThemeCategoryNode else {
            return themeSections.count
        }
        return parent.themes.count
    }
    
    func treeView(_ treeView: LNZTreeView, nodeForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> TreeNodeProtocol {
        guard let parent = parentNode as? ThemeCategoryNode else {
            return themeSections[indexPath.row]
        }
        return parent.themes[indexPath.row]
    }
    
    func treeView(_ treeView: LNZTreeView, cellForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?, isExpanded: Bool) -> UITableViewCell {
        let node: ThemeNode
        let cell: ANEMListThemeTableViewCell
        if let parent = parentNode as? ThemeCategoryNode {
            node = parent.themes[indexPath.row]
            guard let rawCell = treeView.dequeueReusableCell(withIdentifier: "themeRows",
                                                             for: node,
                                                             inSection: indexPath.section) as? ANEMListThemeTableViewCell else {
                                                                fatalError("Wrong Cell Type")
            }
            cell = rawCell
            if node.isEnabled {
                cell.enableButton?.setImage(UIImage(named: "selected"), for: .normal)
            } else {
                cell.enableButton?.setImage(UIImage(named: "unselected"), for: .normal)
            }
        } else {
            node = themeSections[indexPath.row]
            guard let rawCell = treeView.dequeueReusableCell(withIdentifier: "themeSections",
                                                             for: node,
                                                             inSection: indexPath.section) as? ANEMListThemeTableViewCell else {
                                                                fatalError("Wrong Cell Type")
            }
            cell = rawCell
            if node.isEnabled {
                cell.enableButton?.setImage(UIImage(named: "disable"), for: .normal)
            } else {
                cell.enableButton?.setImage(UIImage(named: "enable"), for: .normal)
            }
            cell.enableButton?.block_setAction(block: { _ in
                guard let categoryNode = node as? ThemeCategoryNode else {
                    return
                }
                let enableState = !node.isEnabled
                categoryNode.themes.forEach({ themeNode in
                    themeNode.enabled = enableState
                    treeView.reload(node: themeNode, inSection: indexPath.section)
                })
                treeView.reload(node: node, inSection: indexPath.section)
                self.writeSettings()
            }, for: .touchUpInside)
            if let categoryCell = cell as? ANEMListCategoryTableViewCell {
                categoryCell.themeCategoryNode = node as? ThemeCategoryNode
                categoryCell.reloadTheme()
            }
        }
        cell.themeLabel?.text = node.humanReadable
        return cell
    }
}

extension ANEMThemeListViewController: LNZTreeViewDelegate {
    func treeView(_ treeView: LNZTreeView, canEditRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool {
        true
    }
    
    func treeView(_ treeView: LNZTreeView, editingStyleForNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func treeView(_ treeView: LNZTreeView, shouldIndentWhileEditingRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool {
        false
    }
    
    func treeView(_ treeView: LNZTreeView, canMoveRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool {
        true
    }
    
    func treeView(_ treeView: LNZTreeView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) {
        if let parent = parentNode as? ThemeCategoryNode {
            let element = parent.themes.remove(at: sourceIndexPath.row)
            parent.themes.insert(element, at: destinationIndexPath.row)
        } else {
            let element = themeSections.remove(at: sourceIndexPath.row)
            themeSections.insert(element, at: destinationIndexPath.row)
        }
        writeSettings()
    }
    
    func treeView(_ treeView: LNZTreeView, heightForNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> CGFloat {
        guard (parentNode as? ThemeCategoryNode) != nil else {
            return 95
        }
        return 44
    }
    
    func treeView(_ treeView: LNZTreeView, didSelectNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) {
        let node: ThemeNode
        if let parent = parentNode as? ThemeCategoryNode {
            node = parent.themes[indexPath.row]
            node.enabled = !node.enabled
            treeView.reload(node: node, inSection: indexPath.section)
            treeView.reload(node: parent, inSection: indexPath.section)
            writeSettings()
        }
    }
}

//
//  ANEMThemeListViewController.swift
//  
//
//  Created by CoolStar on 10/28/18.
//

import UIKit

class ANEMThemeListViewController: UIViewController {
    
    @IBOutlet var treeView : LNZTreeView?
    var themeSections : Array<ThemeCategoryNode> = []
    var previewIsStale : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewIsStale = false
        
        UserDefaults.standard.set(UIDevice.current.userInterfaceIdiom.rawValue, forKey: "userInterfaceIdiom");
        UserDefaults.standard.set(UIScreen.main.scale, forKey: "displayScale");
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(ANEMThemeListViewController.toggleEditing))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Preview", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(ANEMThemeListViewController.applyThemes))
        
        treeView?.register(UINib.init(nibName: "ANEMListCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "themeSections")
        treeView?.register(UINib.init(nibName: "ANEMListThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "themeRows")
        
        let themesFolderContents : Dictionary<String, Array<String>> = PackageListManager.shared.scanForThemes() 
        
        let packages : Dictionary<String, Package> = PackageListManager.shared.packagesList()
        
        let rawSettings : Array<Dictionary<String, Any>>? = UserDefaults.standard.array(forKey: "packages") as? Array<Dictionary<String, Any>>
        
        var rawOrderedPackages : Array<String> = []
        var rawHashedPackages : Dictionary<String, Array<Dictionary<String, Any>>> = [:]
        rawSettings?.forEach { (rawPackage) in
            guard let identifier = rawPackage["identifier"] as? String else {
                return
            }
            rawOrderedPackages.append(identifier)
            
            rawHashedPackages[identifier] = rawPackage["themes"] as? [Dictionary<String, Any>]
        }
        
        var sectionsDict : Dictionary<String, ThemeCategoryNode> = [:]
        themesFolderContents.forEach { (arg0) in
            let (themeIdentifier, themeFolders) = arg0
            
            let rawThemes = rawHashedPackages[themeIdentifier]
            var orderedThemes : Array<String> = []
            var hashedThemes : Dictionary<String, Bool> = [:]
            rawThemes?.forEach({ (rawTheme) in
                guard let rawThemeName = rawTheme["name"] as? String else {
                    return
                }
                guard let rawThemeEnabled = rawTheme["enabled"] as? Bool else {
                    return
                }
                if (themeFolders.contains(rawThemeName)){
                    orderedThemes.append(rawThemeName)
                    hashedThemes[rawThemeName] = rawThemeEnabled
                }
            })
            
            let node : ThemeCategoryNode = ThemeCategoryNode()
            
            let package : Package? = packages[themeIdentifier]
            
            node.identifier = themeIdentifier
            node.humanReadable = package?.name ?? themeIdentifier
            if (themeIdentifier == "com.anemonetheming.unknown"){
                node.humanReadable = NSLocalizedString("Miscellaneous", comment: "")
            }
            
            var hashedNodeThemes : Dictionary<String, ThemeNode> = [:]
            
            themeFolders.forEach({ (folder) in
                let themeNode : ThemeNode = ThemeNode()
                themeNode.identifier = folder
                
                let folderStr : NSString = folder as NSString
                
                themeNode.humanReadable = folderStr.deletingPathExtension
                themeNode.enabled = hashedThemes[folder] ?? false
                hashedNodeThemes[folder] = themeNode
                
                if (!orderedThemes.contains(folder)){
                    orderedThemes.append(folder)
                }
            })
            
            orderedThemes.forEach({ (folder) in
                node.themes.append(hashedNodeThemes[folder]!)
            })
            
            sectionsDict[themeIdentifier] = node
            if (!rawOrderedPackages.contains(themeIdentifier)){
                rawOrderedPackages.append(themeIdentifier)
            }
        }
        
        rawOrderedPackages.forEach { (identifier) in
            if (sectionsDict[identifier] != nil){
                themeSections.append(sectionsDict[identifier]!)
            }
        }

        // Do any additional setup after loading the view.
    }

    @objc func toggleEditing(){
        treeView?.setEditing(!(treeView?.isEditing)!, animated: true)
        if ((treeView?.isEditing)!){
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(ANEMThemeListViewController.toggleEditing))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(ANEMThemeListViewController.toggleEditing))
        }
    }
    
    func writeSettings(){
        var settings : Array<Dictionary<String, Any>> = []
        themeSections.forEach { (themeFolder) in
            var themePackage : Dictionary<String, Any> = [:]
            themePackage["identifier"] = themeFolder.identifier
            
            var themes : Array<Dictionary<String, Any>> = []
            themeFolder.themes.forEach({ (themeNode) in
                var theme : Dictionary<String, Any> = [:]
                theme["name"] = themeNode.identifier
                theme["enabled"] = themeNode.enabled
                themes.append(theme)
            })
            themePackage["themes"] = themes
            settings.append(themePackage)
        }
        UserDefaults.standard.set(settings, forKey: "packages")
        
        var settingsPacked : Array<String> = []
        settings.forEach { (themePackage) in
            guard let themes = themePackage["themes"] as? Array<Dictionary<String, Any>> else {
                return
            }
            themes.forEach({ (theme) in
                guard let themeEnabled = theme["enabled"] as? Bool else {
                    return
                }
                guard let themeName = theme["name"] as? String else {
                    return
                }
                if (themeEnabled == true){
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
        if ((self.splitViewController?.isCollapsed)!){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Preview", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(ANEMThemeListViewController.applyThemes))
        } else {
            if (previewIsStale){
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Refresh Preview", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(ANEMThemeListViewController.applyThemes))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Apply", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(ANEMThemeListViewController.applyThemes))
            }
        }
    }
    
    @objc func applyThemes(){
        if ((self.splitViewController?.isCollapsed)!){
            let previewController : ANEMPreviewController = ANEMPreviewController()
            let navController = UINavigationController(rootViewController: previewController)
            self.present(navController, animated: true){
                
            }
        } else {
            let previewController : ANEMPreviewController = self.splitViewController?.viewControllers[1] as! ANEMPreviewController
            if (previewIsStale){
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

extension ANEMThemeListViewController : LNZTreeViewDataSource {
    func numberOfSections(in treeView: LNZTreeView) -> Int {
        return 1
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
        let cell : ANEMListThemeTableViewCell
        if let parent = parentNode as? ThemeCategoryNode {
            node = parent.themes[indexPath.row]
            cell = treeView.dequeueReusableCell(withIdentifier: "themeRows", for: node, inSection: indexPath.section) as! ANEMListThemeTableViewCell
            if (node.isEnabled){
                cell.enableButton?.setImage(UIImage(named: "selected"), for: UIControl.State.normal)
            } else {
                cell.enableButton?.setImage(UIImage(named: "unselected"), for: UIControl.State.normal)
            }
        } else {
            node = themeSections[indexPath.row]
            cell = treeView.dequeueReusableCell(withIdentifier: "themeSections", for: node, inSection: indexPath.section) as! ANEMListThemeTableViewCell
            if (node.isEnabled){
                cell.enableButton?.setImage(UIImage(named: "disable"), for: UIControl.State.normal)
            } else {
                cell.enableButton?.setImage(UIImage(named: "enable"), for: UIControl.State.normal)
            }
            cell.enableButton?.block_setAction(block: { (enableButton) in
                guard let categoryNode = node as? ThemeCategoryNode else {
                    return
                }
                let enableState = !node.isEnabled;
                categoryNode.themes.forEach({ (themeNode) in
                    themeNode.enabled = enableState
                    treeView.reload(node: themeNode, inSection: indexPath.section)
                })
                treeView.reload(node: node, inSection: indexPath.section)
                self.writeSettings()
            }, for: UIControl.Event.touchUpInside)
            let categoryCell : ANEMListCategoryTableViewCell = cell as! ANEMListCategoryTableViewCell
            categoryCell.themeCategoryNode = node as? ThemeCategoryNode
            categoryCell.reloadTheme()
        }
        cell.themeLabel?.text = node.humanReadable
        return cell
    }
}

extension ANEMThemeListViewController : LNZTreeViewDelegate {
    func treeView(_ treeView: LNZTreeView, canEditRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool {
        return true
    }
    
    func treeView(_ treeView: LNZTreeView, editingStyleForNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func treeView(_ treeView: LNZTreeView, shouldIndentWhileEditingRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool {
        return false
    }
    
    func treeView(_ treeView: LNZTreeView, canMoveRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> Bool {
        return true
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

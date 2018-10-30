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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(ANEMThemeListViewController.toggleEditing))
        
        treeView?.register(UINib.init(nibName: "ANEMListCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "themeSections")
        treeView?.register(UINib.init(nibName: "ANEMListThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "themeRows")
        
        let themesFolderContents : Dictionary<String, Array<String>> = PackageListManager.sharedInstance().scanForThemes() as! Dictionary<String, Array>
        
        let packages : Dictionary<String, Package> = PackageListManager.sharedInstance().packagesList()
        
        let rawSettings : Array<Dictionary<String, Any>>? = UserDefaults.standard.array(forKey: "packages") as? Array<Dictionary<String, Any>>
        
        var rawOrderedPackages : Array<String> = []
        var rawHashedPackages : Dictionary<String, Array<Dictionary<String, Any>>> = [:]
        rawSettings?.forEach { (rawPackage) in
            let identifier : String = rawPackage["identifier"] as! String
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
                if (((rawTheme["name"] as? String) != nil) && ((rawTheme["enabled"] as? Bool) != nil)){
                    orderedThemes.append((rawTheme["name"] as? String)!)
                    hashedThemes[rawTheme["name"] as! String] = (rawTheme["enabled"] as! Bool)
                }
            })
            
            let node : ThemeCategoryNode = ThemeCategoryNode()
            
            let package : Package? = packages[themeIdentifier]
            
            node.identifier = themeIdentifier
            node.humanReadable = package?.name ?? themeIdentifier
            
            var hashedNodeThemes : Dictionary<String, ThemeNode> = [:]
            
            themeFolders.forEach({ (folder) in
                let themeNode : ThemeNode = ThemeNode()
                themeNode.identifier = folder
                
                let folderStr : NSString = folder as NSString
                
                themeNode.humanReadable = folderStr.deletingPathExtension
                if (hashedThemes[folder] != nil){
                    themeNode.enabled = hashedThemes[folder]!
                } else {
                    themeNode.enabled = false
                }
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
                let categoryNode : ThemeCategoryNode = node as! ThemeCategoryNode
                let enableState : Bool = !node.isEnabled;
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
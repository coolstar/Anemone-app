import Foundation
import UIKit
import ObjectiveC

var actionBlockKey: UInt8 = 0

// a type for our action block closure
typealias BlockButtonActionBlock = (_ sender: UIButton) -> Void

class ActionBlockWrapper {
    var block: BlockButtonActionBlock
    init(block: @escaping BlockButtonActionBlock) {
        self.block = block
    }
}

extension UIButton {
    func block_setAction(block: @escaping BlockButtonActionBlock, for control: UIControl.Event) {
        objc_setAssociatedObject(self, &actionBlockKey, ActionBlockWrapper(block: block), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.addTarget(self, action: #selector(UIButton.block_handleAction), for: .touchUpInside)
    }
    
    @objc func block_handleAction(sender: UIButton, for control: UIControl.Event) {
        
        if let wrapper = objc_getAssociatedObject(self, &actionBlockKey) as? ActionBlockWrapper {
            wrapper.block(sender)
        }
    }
}

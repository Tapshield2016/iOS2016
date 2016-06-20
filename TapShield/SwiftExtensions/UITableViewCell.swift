//
//  UITableViewCell.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import UIKit

public extension UITableViewCell {
    
    class func registerNibWithTableView(tableView: UITableView) {
        tableView.registerNib(self.nib, forCellReuseIdentifier:self.className)
    }
    
    class func registerClassWithTableView(tableView: UITableView) {
        
        tableView.registerClass(self, forCellReuseIdentifier:self.className);
    }
    
    class var cellHeight: CGFloat {
        return 50.0;
    }
    
    var superTableView: UITableView? {
        
        return self.superview?.superview as? UITableView
    }
    
    var indexPath: NSIndexPath? {
        
        return self.superTableView?.indexPathForCell(self)
    }
    
    func setSelectedCellAnimated(animated: Bool, scrollPosition: UITableViewScrollPosition) {
        
        let tableView = self.superTableView
        
        if let indexPath = self.indexPath {
            tableView?.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:scrollPosition)
            tableView?.delegate?.tableView?(tableView!, didSelectRowAtIndexPath:indexPath)
        }
    }
}
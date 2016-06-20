//
//  UITableVIew.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import UIKit


public extension UITableView {
    
    func hideEmptyCells() {
        self.tableFooterView = UIView(frame:CGRectZero)
    }
    
    func registerNibClasses(classes: [UITableViewCell.Type]) {
    
        classes.each({ $0.registerNibWithTableView(self)})
    }
    
    func registerClasses(classes: [UITableViewCell.Type]) {
        
        classes.each({ $0.registerClassWithTableView(self)})
    }
    
    func nextEstimatedContentSize() -> CGSize {
        
        var size = CGSizeZero
        size.width = self.frame.size.width
        
        if let sections = self.dataSource?.numberOfSectionsInTableView?(self) {
            
            for section in 0...sections {
                
                size.height += self.delegate!.tableView!(self, estimatedHeightForHeaderInSection:section)
                size.height += self.delegate!.tableView!(self, estimatedHeightForFooterInSection:section)
                
                let rows = self.dataSource!.tableView(self, numberOfRowsInSection: section)
                
                for row in 0...rows {
                    size.height += self.delegate!.tableView!(self, estimatedHeightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: section))
                }
            }
        }
        
        return size
    }
}
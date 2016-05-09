//
//  UITabBarController.swift
//  Pods
//
//  Created by Adam J Share on 11/9/15.
//
//

import Foundation
import UIKit

public extension UITabBarController {
    
    func addCenterButtonWithImage(buttonImage: UIImage, highlightImage: UIImage) -> UIButton {
    
        let button = UIButton(type:.Custom)
        button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
        button.setBackgroundImage(buttonImage, forState:.Normal)
        button.setBackgroundImage(highlightImage, forState:.Highlighted)
        button.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin]
    
        self.addButtonToCenter(button)
    
        return button;
    }
    
    func addButtonToCenter(button: UIButton) {
    
        button.addTarget(self, action: #selector(UITabBarController.didSelectCenterButton(_:)), forControlEvents: .TouchUpInside)
        let heightDifference = button.frame.size.height - self.tabBar.frame.size.height;
    
        if (heightDifference < 0) {
            button.center = self.tabBar.center;
        }
        else {
            var center = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
    
        if let items = self.tabBar.items {
            let item = items[items.count/2];
            item.enabled = false;
        }
    
        self.view.addSubview(button)
    }
    
    func didSelectCenterButton(sender: UIButton) {
    
        
    }
}
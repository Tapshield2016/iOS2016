//
//  UIStoryboard.swift
//  Pods
//
//  Created by Adam J Share on 11/2/15.
//
//

import Foundation
import UIKit

public extension UIStoryboard {
    
    public class func defaultStoryboard() -> UIStoryboard {
        
        return self.mainBundleStoryboard("Main")
    }
    
    public class func mainBundleStoryboard(name: String) -> UIStoryboard {
        
        return UIStoryboard(name: name, bundle: NSBundle.mainBundle())
    }
}
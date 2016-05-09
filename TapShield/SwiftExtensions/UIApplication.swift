//
//  UIApplication.swift
//  Pods
//
//  Created by Adam J Share on 11/4/15.
//
//

import Foundation
import UIKit

public extension UIApplication {
    
    public class func openSettings() {
        self.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
    }
}
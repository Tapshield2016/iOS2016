//
//  UINavigationController.swift
//  Pods
//
//  Created by Adam J Share on 11/4/15.
//
//

import UIKit

public extension UINavigationController {
    
    //MARK: - Set Stack
    
    func setRootViewControllerByClass(controllerClass: UIViewController.Type, animated: Bool = true) -> UIViewController {
        
        let controller = controllerClass.instantiateFromStoryboard()
    
        self.setViewControllers([controller], animated: animated)
        
        return controller
    }
    
    func addViewControllersByClasses(classes: [UIViewController.Type], animated: Bool = true) -> [UIViewController] {
        
        var controllers: [UIViewController] = self.viewControllers
        
        for type in classes {
            controllers.append(type.instantiateFromStoryboard())
        }
        
        self.setViewControllers(controllers, animated: animated)
        
        return controllers
    }
    
    func setViewControllersByClasses(classes: [UIViewController.Type], animated: Bool = true) -> [UIViewController] {
        
        var controllers: [UIViewController] = []
        
        for type in classes {
            controllers.append(type.instantiateFromStoryboard())
        }
        
        self.setViewControllers(controllers, animated: animated)
        
        return controllers
    }
    
    //MARK: Utils
    
    func clearNavBarAnimated(animated: Bool) {
        
        if (animated) {
            let transition = CATransition()
            transition.duration = 0.3;
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromRight;
            transition.delegate = self;
            self.navigationBar.layer.removeAnimationForKey("NAVBACKGROUND-Fade")
            self.navigationBar.layer.addAnimation(transition, forKey:"NAVBACKGROUND-Fade")
        }
    
        self.clearNavBar()
    }
    
    func clearNavBar() {
        if !self.isClearNavBar {
            self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.translucent = true;
            self.navigationBar.tintColor = UIColor.whiteColor()
        }
    }
    
    var isClearNavBar: Bool {
        return self.navigationBar.shadowImage != nil || self.navigationBar.backgroundImageForBarMetrics(.Default) != nil
    }
    
    func standardNavBarAnimated(animated: Bool) {
        
        if (animated) {
            let transition = CATransition()
            transition.duration = 0.3;
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromRight;
            transition.delegate = self;
            self.navigationBar.layer.removeAnimationForKey("NAVBACKGROUND-Fade")
            self.navigationBar.layer.addAnimation(transition, forKey:"NAVBACKGROUND-Fade")
        }
        
        self.standardNavBar()
    }
    
    func standardNavBar() {
        if self.isClearNavBar {
            self.navigationBar.setBackgroundImage(nil, forBarMetrics:.Default)
            self.navigationBar.shadowImage = nil;
        }
    }
    
    func blackGradientBar() {
    
        self.clearNavBar()
    
        var frame = self.navigationBar.bounds;
        frame.origin.y = -UIApplication.sharedApplication().statusBarFrame.size.height;
        frame.size.height += UIApplication.sharedApplication().statusBarFrame.size.height;
        let view = UIView(frame: frame)
        view.addGradientWithColor(UIColor.blackColor(), endColor: UIColor.clearColor(), startPoint: CGPointMake(0.5, 0.0), endPoint:CGPointMake(0.5, 1.0))
    
        self.navigationBar.insertSubview(view, atIndex:0)
    }
}
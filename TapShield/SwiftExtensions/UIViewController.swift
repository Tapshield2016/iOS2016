//
//  UIViewController.swift
//  Pods
//
//  Created by Adam J Share on 11/2/15.
//
//

import Foundation
import UIKit

public extension UIViewController {
    
    var topBarHeight: CGFloat {
        
        var topHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        if let height = self.navigationController?.navigationBar.frame.size.height {
            topHeight += height
        }
        
        return topHeight
    }
    
    
    //MARK: - Instantiate
    
    class func instantiateFromStoryboard<T: UIViewController>(name: String? = nil, identifier: String? = nil) -> T {
        
        var id: String! = identifier
        
        if identifier == nil {
            id = self.className
        }
        
        if name == nil {
            return UIStoryboard.defaultStoryboard().instantiateViewControllerWithIdentifier(id!) as! T
        }
        
        return UIStoryboard(name: name!, bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier(id!) as! T
    }
    
    //MARK: - Add/Remove
    
    func addViewController(viewController: UIViewController, view: UIView, bounds: CGRect = CGRectNull, autoLayout: Bool = true) {
        
        var frame = bounds
        
        if frame == CGRectNull {
            frame = view.bounds
        }
        
        self.addChildViewController(viewController)
        viewController.view.frame = frame;
        view.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        
        
        if (autoLayout)
        {
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false;
            
            let attributes: [NSLayoutAttribute] = [.Left, .Top, .Width, .Height]
            
            for attribute in attributes {
                
                self.view.addConstraint(NSLayoutConstraint(item: view, attribute:attribute, relatedBy:.Equal, toItem:viewController.view, attribute:attribute, multiplier:1, constant:0))
            }
        }
    }
    
    func removeFromParentSuperview() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
    //MARK: - Present
    
    func presentViewControllerByClass<T: UIViewController>(vcClass: T.Type, animated: Bool = true, style: UIModalPresentationStyle = .FullScreen, completion: ((Void) -> Void)? = nil) -> T {
        
        let viewController: T = vcClass.instantiateFromStoryboard()
        let root = self.presentRootViewController(viewController, animated: animated, style: style, completion: completion)
        return root
    }
    
    func objcPresentViewControllerByClass(vcClass: UIViewController.Type, animated: Bool = true, style: UIModalPresentationStyle = .FullScreen, completion: ((Void) -> Void)? = nil) -> AnyObject {
        return self.presentViewControllerByClass(vcClass, animated: animated, style: style, completion: completion)
    }
    
    func presentRootViewController<T: UIViewController>(rootViewController: T, animated: Bool = true, style: UIModalPresentationStyle = .FullScreen, completion: ((Void) -> Void)? = nil) -> T {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.modalPresentationStyle = style;
        rootViewController.modalPresentationStyle = style;
        
        self.presentViewController(navController, animated: animated, completion: completion)
        
        return rootViewController
    }
    
    func presentNavigationControllerByClass<T: UINavigationController>(vcClass: T.Type, animated: Bool = true, style: UIModalPresentationStyle = .FullScreen, completion: ((Void) -> Void)? = nil) -> T {
        
        let navController: T = vcClass.instantiateFromStoryboard()
        
        navController.modalPresentationStyle = style;
        
        self.presentViewController(navController, animated: animated, completion: completion)
        
        return navController
    }
    
    //MARK: - Push
    
    func pushViewControllerByClass<T: UIViewController>(controllerClass: T.Type, animated: Bool = true) -> T {
        
        let vc: T = controllerClass.instantiateFromStoryboard()
        
        self.navigationController?.pushViewController(vc, animated: animated)
        return vc
    }
    
    func objcPushViewControllerByClass(controllerClass: UIViewController.Type, animated: Bool = true) -> AnyObject {
        return self.pushViewControllerByClass(controllerClass, animated: animated)
    }
    
    //MARK: - Dismiss
    
    func dismissAllPresentedViewControllersAnimated(flag: Bool, completion: (() -> Void)?) {
        
        self.firstPresentedViewController?.presentingViewController?.dismissViewControllerAnimated(flag, completion: completion)
    }
    
    //MARK: - Hierarchy
    
    var firstPresentedViewController: UIViewController? {
        
        var viewController = self.presentedViewController
        
        while viewController?.presentingViewController != self && viewController?.presentingViewController != self.navigationController {
            
            viewController = viewController?.presentingViewController
            
            if viewController == nil {
                return nil
            }
        }
        
        if let controller = (viewController as? UINavigationController)?.viewControllers.first {
            return controller
        }
        
        return viewController
    }
    
    var isFirstController: Bool {
        
        return self.navigationController?.viewControllers.first == self
    }
    
    var topLevelController: UIViewController {
        
        if self.presentedViewController == nil {
            return self
        }
        
        return self.presentedViewController!.topLevelController
    }
    
    var isRootViewController: Bool {
        return self.navigationController?.viewControllers.count <= 1;
    }
    
    class var topViewController: UIViewController {
        
        let rootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
        return self.topViewControllerWithRootViewController(rootViewController!)
    }
    
    class func topViewControllerWithRootViewController(rootViewController: UIViewController) -> UIViewController {
        // Handling UITabBarController
        
        if let rootViewController = rootViewController as? UITabBarController, let selected = rootViewController.selectedViewController {
            return self.topViewControllerWithRootViewController(selected)
        }
        else if let rootViewController = rootViewController as? UINavigationController, let visible = rootViewController.visibleViewController {
            return self.topViewControllerWithRootViewController(visible)
        }
        else if let presentedViewController = rootViewController.presentedViewController {
            return self.topViewControllerWithRootViewController(presentedViewController)
        }
        
        return rootViewController
    }
}
//
//  UIView.swift
//  Pods
//
//  Created by Adam J Share on 11/4/15.
//
//

import UIKit

public extension UIView {
    
    func clearBackground() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    func rounded() {
        self.clipsToBounds = true;
        self.layer.cornerRadius = self.frame.size.height * 0.50;
    }
    
    func removeAllSubviews() {
        self.subviews.each { $0.removeFromSuperview() }
    }
    
    //MARK: - Nib
    
    class var nib: UINib {
        return UINib(nibName: self.className, bundle: NSBundle.mainBundle())
    }
    
    //MARK: - Font
    
    func setFontName(name: String) {
        
        if let font = self.rvt_font {
            if let newFont = UIFont(name: name, size: font.pointSize) {
                self.rvt_setFont(newFont)
            }
        }
    }
    
    func setFontSize(pointSize: CGFloat) {
        
        if let font = self.rvt_font {
            if let newFont = UIFont(name: font.fontName, size: pointSize) {
                self.rvt_setFont(newFont)
            }
        }
    }
    
    private func rvt_setFont(font: UIFont) {
        
        if self.respondsToSelector(Selector("setFont:")) {
            self.performSelector(Selector("setFont:"), withObject: font)
        }
    }
    
    private var rvt_font: UIFont? {
        
        if self.respondsToSelector(Selector("font")) {
            if let font = self.performSelector(
                Selector("font")) as? AnyObject as? UIFont {
                    return font
            }
        }
        
        return nil
    }
    
    func addInnerShadowForPath(maskPath: CGPathRef, color: UIColor) {
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = self.bounds;
        
        shadowLayer.shadowColor = color.CGColor;
        shadowLayer.shadowOffset = CGSizeZero;
        shadowLayer.shadowOpacity = 0.8;
        shadowLayer.shadowRadius = self.frame.size.height * 0.05;
        
        shadowLayer.fillRule = kCAFillRuleEvenOdd;
        
        // Create the larger rectangle path.
        let path = CGPathCreateMutable();
        CGPathAddRect(path, nil, CGRectInset(self.bounds, -20, -20));
        
        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.
        CGPathAddPath(path, nil, maskPath);
        CGPathCloseSubpath(path);
        
        shadowLayer.path = path;
        shadowLayer.masksToBounds = true;
        
        self.layer.addSublayer(shadowLayer)
    }
    
    var asImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale);
        
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    func addGradientWithColor(startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint, frame: CGRect? = nil) -> CAGradientLayer {
        
        var frame = frame
        if frame == nil {
            frame = self.bounds
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame!;
        gradientLayer.colors = [startColor.CGColor, endColor.CGColor]
        gradientLayer.startPoint = startPoint;
        gradientLayer.endPoint = endPoint;
        self.layer.addSublayer(gradientLayer)
        
        return gradientLayer;
    }
    
    var currentFirstResponder: UIView? {
        
        if self.isFirstResponder() {
            return self;
        }
        
        for subView in self.subviews {
            if let firstResponder = subView.currentFirstResponder {
                return firstResponder;
            }
        }
        
        return nil;
    }
    
    func setRoundBezierPathMask(radius: CGFloat, corners: UIRectCorner = .AllCorners) {
        
        let maskPath = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:corners, cornerRadii:CGSizeMake(radius, radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
    
    var contentCenter: CGPoint {
        return CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    
    func pointFromCenterWithRadius(radius: CGFloat, angle: CGFloat) -> CGPoint {
        var newPoint = CGPoint()
        newPoint.x = self.center.x + (radius * cos(angle * CGFloat(M_PI / 180)));
        newPoint.y = self.center.y + (radius * sin(angle * CGFloat(M_PI / 180)));
        
        return newPoint;
    }
    
    var debugQuickLookObject: AnyObject {
        return self.asImage
    }
    
    
    
    //MARK: Parallax
    
    func addCenterParallaxEffectHorizontal(value: CGFloat) {
        
        let parallaxEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        parallaxEffect.minimumRelativeValue = -value;
        parallaxEffect.maximumRelativeValue = value
        
        self.addMotionEffect(parallaxEffect)
    }
    
    func addCenterParallaxEffectVertical(value: CGFloat) {
        
        let parallaxEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        parallaxEffect.minimumRelativeValue = -value;
        parallaxEffect.maximumRelativeValue = value
        
        self.addMotionEffect(parallaxEffect)
    }
    
    var baseSuperView: UIView {
        
        if let superView = self.superview {
            return superView.baseSuperView;
        }
        
        return self;
    }
    
    func dropShadow(add: Bool) {
        
        if (add) {
            self.layer.shadowColor = UIColor.blackColor().CGColor;
            self.layer.shadowOpacity = 0.2;
            self.layer.shadowOffset = CGSizeMake(0, 2);
            self.layer.shadowRadius = 2;
        }
        else {
            self.layer.shadowOpacity = 0;
            self.layer.shadowOffset = CGSizeZero;
            self.layer.shadowRadius = 0;
        }
    }
    
    func dashedBorderWithColor(color: UIColor) -> CAShapeLayer {
        
        let shapeLayer = CAShapeLayer()
        
        let frameSize = self.frame.size;
        
        let shapeRect = CGRectMake(0.0, 0.0, frameSize.width, frameSize.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPointMake(frameSize.width/2, frameSize.height/2)
        
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color.CGColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.lineJoin = kCALineCapSquare
        shapeLayer.lineDashPattern = [10, 5]
        let path = UIBezierPath(roundedRect: shapeRect, cornerRadius:5.0)
        shapeLayer.path = path.CGPath
        
        return shapeLayer;
    }
}

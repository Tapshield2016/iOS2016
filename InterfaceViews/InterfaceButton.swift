//
//  InterfaceButton.swift
//  Pods
//
//  Created by Adam J Share on 11/12/15.
//
//

import UIKit

@IBDesignable
public class InterfaceButton: UIButton {

    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable public var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
    @IBInspectable public var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.CGColor
        }
    }
    
    @IBInspectable public var shadowOffset: CGSize = CGSizeZero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable public var shadowOpacity: Float = 0{
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 0{
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable public var dropShadow: Bool = false {
        
        didSet {
            if (dropShadow) {
                self.shadowColor = UIColor.blackColor()
                self.shadowOffset = CGSizeMake(0, 2);
                self.shadowOpacity = 0.2;
                self.shadowRadius = 2;
            }
            else {
                self.shadowOpacity = 0.0;
                self.shadowRadius = 0.0;
            }
        }
    }
    
    
    public var dashedShapeLayer: CAShapeLayer?
    
    @IBInspectable public var dashedBorderColor: UIColor? {
        
        didSet {
            dashedShapeLayer?.removeFromSuperlayer()
            
            if let color = dashedBorderColor {
                dashedShapeLayer = self.dashedBorderWithColor(color)
                self.layer.addSublayer(dashedShapeLayer!)
            }
        }
    }
    
    @IBInspectable public var round: Bool = false
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = dashedShapeLayer {
            let frameSize = self.frame.size
            let shapeRect = CGRectMake(0.0, 0.0, frameSize.width, frameSize.height)
            layer.frame = shapeRect
            let path = UIBezierPath(roundedRect: shapeRect, cornerRadius:5.0)
            
            dashedShapeLayer?.path = path.CGPath
        }
        
        if round == true {
            var minLength = self.frame.size.width;
            
            if self.frame.size.height < minLength {
                minLength = self.frame.size.height;
            }
            
            self.cornerRadius = minLength/2;
        }
    }
    
    
    @IBInspectable public var tapMargin: CGRect = CGRectZero
    
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    
        var bounds = self.bounds;
        bounds.origin.x -= tapMargin.origin.x;
        bounds.origin.y -= tapMargin.origin.y;
        bounds.size.width += tapMargin.origin.x + tapMargin.size.width;
        bounds.size.height += tapMargin.origin.y + tapMargin.size.height;
    
        if (CGRectContainsPoint(bounds, point)) {
            return true;
        }
    
        return super.pointInside(point, withEvent: event)
    }
    
    
//    @IBInspectable public var backgroundImageColor: UIColor? {
//        didSet {
//            layer.cornerRadius = cornerRadius
//            layer.masksToBounds = cornerRadius > 0
//        }
//    }
    
}

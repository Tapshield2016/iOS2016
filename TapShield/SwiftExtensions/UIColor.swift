//
//  UIColor.swift
//  Pods
//
//  Created by Adam J Share on 11/9/15.
//
//

import Foundation
import UIKit

public extension UIColor {
    
    class var ravtiGreenColor: UIColor {
        
        return UIColor(hex: "6FC99B")//0x57B8A0);
    }
    
    class var ravtiYellowColor: UIColor {
        //    F4D829
        return UIColor(hex: "F3CA50")//e4e516);
    }
    
    //class var ravtiDarkBlueColor: UIColor {
    //
    //    return UIColor(hex: "0456CE")
    //}
    
    //class var ravtiGreenColor {
    //
    //    return UIColor(hex: "0DC168")
    //}
    
    class var ravtiBlueColor: UIColor {
        
        return UIColor(hex: "488EE8")//0456CE);
    }
    
    class var ravtiPinkColor: UIColor {
        
        return UIColor(hex: "CB2289")
    }
    
    class var ravtiOrangeColor: UIColor {
        
        return UIColor(hex: "C1560D")
    }
    
    class var ravtiPurpleColor: UIColor {
        
        return UIColor(hex: "8F9EFF")//CB2289")
    }
    
    class var ravtiRedColor: UIColor {
        
        return UIColor(hex: "EE4249")//F44029")
    }
    
    //class var ravtiDarkRedColor: UIColor {
    //
    //    return UIColor(hex: "C9404E")
    //}
}


public extension UIColor {
    
    var hue: CGFloat {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return h
    }
    
    var saturation: CGFloat {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return s
    }
    
    var alpha: CGFloat {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return a
    }
    
    var brightness: CGFloat {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return b
    }
    
    func colorWithBrightness(brightness: CGFloat) -> UIColor? {
        
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: brightness, alpha: a)
        }
        
        return nil
    }
    
    func colorByChangingBrightness(change: CGFloat) -> UIColor? {
        
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: min(brightness+b, 1.0), alpha: a)
        }
        
        return nil
    }
    
    func brighten() -> UIColor? {
        return self.colorByChangingBrightness(0.1)
    }
    
    func darken() -> UIColor? {
        return self.colorByChangingBrightness(-0.1)
    }
    
    var image: UIImage {
        return UIImage(color: self)!
    }
    
    var debugQuickLookObject: AnyObject {
        return UIImage(color: self, size: CGSize(width: 50, height: 50))!
    }
    
    func isEqualToColor(otherColor: UIColor) -> Bool {
        
        return self.RGBSpaceColor == otherColor.RGBSpaceColor
    }
    
    var RGBSpaceColor: UIColor {
        
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
        
        let oldComponents = CGColorGetComponents(self.CGColor);
        let components = [oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]]
        if let colorRef = CGColorCreate( colorSpaceRGB, components ) {
            return UIColor(CGColor: colorRef)
        }
        
        return self;
    }
    
    convenience init(hex: String, alpha: CGFloat = 1) {
        
        let cleanString = hex.stringByReplacingOccurrencesOfString("#", withString: "")
        
        var hexString = cleanString
        
        if cleanString.characters.count == 3 {
            var characters: [Character] = []
            for character in cleanString.characters {
                characters.append(character)
                characters.append(character)
            }
            hexString = String(characters)
        }
        
        if hexString.characters.count == 6 {
            hexString += "ff"
        }
        
        var baseValue: UInt32 = 0
        NSScanner(string: hexString).scanHexInt(&baseValue)
        
        let red = CGFloat((baseValue >> 24) & 0xFF)/255.0
        let green = CGFloat((baseValue >> 16) & 0xFF)/255.0
        let blue = CGFloat((baseValue >> 8) & 0xFF)/255.0
        
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    var rgbHex: UInt32 {
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        if !self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return 0
        }
        
        r = min(max(r, 0.0), 1.0)
        g = min(max(g, 0.0), 1.0)
        b = min(max(b, 0.0), 1.0)
        
        return (UInt32(round(r * CGFloat(255))) << 16)
            | (UInt32(round(g * CGFloat(255))) << 8)
            | (UInt32(round(b * CGFloat(255))));
    }
    
    
    //
    //    - (NSString *)hexFromColor
    //    {
    //    return [NSString stringWithFormat:@"%0.6X", (unsigned int)self.rgbHex];
    //    }
    ////
    //    - (UInt32)rgbHex {
    //    assert(self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
    //
    //    CGFloat r,g,b,a;
    //    if (![self red:&r green:&g blue:&b alpha:&a]) return 0;
    //
    //    r = MIN(MAX(r, 0.0f), 1.0f);
    //    g = MIN(MAX(g, 0.0f), 1.0f);
    //    b = MIN(MAX(b, 0.0f), 1.0f);
    //
    //    return (((int)roundf(r * 255)) << 16)
    //    | (((int)roundf(g * 255)) << 8)
    //    | (((int)roundf(b * 255)));
    //    }
    //
    //    - (BOOL)red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    //    const CGFloat *components = CGColorGetComponents(self.CGColor);
    //
    //    CGFloat r,g,b,a;
    //
    //    switch (self.colorSpaceModel) {
    //    case kCGColorSpaceModelMonochrome:
    //    r = g = b = components[0];
    //    a = components[1];
    //    break;
    //    case kCGColorSpaceModelRGB:
    //    r = components[0];
    //    g = components[1];
    //    b = components[2];
    //    a = components[3];
    //    break;
    //    default:	// We don't know how to handle this model
    //    return NO;
    //    }
    //
    //    if (red) *red = r;
    //    if (green) *green = g;
    //    if (blue) *blue = b;
    //    if (alpha) *alpha = a;
    //
    //    return YES;
    //    }
    //
    
    
    var red: CGFloat {
        assert(self.canProvideRGBComponents, "Must be an RGB color to use -red")
        let c = CGColorGetComponents(self.CGColor);
        return c[0]
    }
    
    var green: CGFloat {
        assert(self.canProvideRGBComponents, "Must be an RGB color to use -green");
        let c = CGColorGetComponents(self.CGColor);
        if (self.colorSpaceModel == .Monochrome) {
            return c[0]
        }
        return c[1]
    }
    
    var blue: CGFloat {
        assert(self.canProvideRGBComponents, "Must be an RGB color to use -blue");
        let c = CGColorGetComponents(self.CGColor);
        if (self.colorSpaceModel == .Monochrome) {
            return c[0]
        }
        return c[2]
    }
    
    var white: CGFloat {
        assert(self.colorSpaceModel == .Monochrome, "Must be a Monochrome color to use -white");
        let c = CGColorGetComponents(self.CGColor);
        return c[0]
    }
    
    var colorSpaceModel: CGColorSpaceModel {
        return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    }
    
    var canProvideRGBComponents: Bool {
        switch (self.colorSpaceModel) {
        case .RGB, .Monochrome:
            return true;
        default:
            return false;
        }
    }
    
}
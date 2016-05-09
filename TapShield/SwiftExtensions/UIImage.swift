//
//  UIImage.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import Foundation
import UIKit

public extension UIImage {
    
    public convenience init?(ravtiImageNamed: String) {
        
        if let resourcePath = NSBundle.mainBundle().resourcePath {
            let path = resourcePath + "/Frameworks/RavtiSDK.framework/RavtiSDKResources.bundle"
            if let ravtiBundle = NSBundle(path: path) {
                self.init(named: ravtiImageNamed, inBundle: ravtiBundle, compatibleWithTraitCollection: nil)
                return
            }
        }
        
        self.init(named: ravtiImageNamed)
    }
    
    public class func ravtiImageNamed(name: String) -> UIImage? {
        
        if let resourcePath = NSBundle.mainBundle().resourcePath {
            let path = resourcePath + "/Frameworks/RavtiSDK.framework/RavtiSDKResources.bundle"
            if let ravtiBundle = NSBundle(path: path) {
                return UIImage(named: name, inBundle: ravtiBundle, compatibleWithTraitCollection: nil)
            }
        }
        
        return nil
    }
    
    
    convenience init?(color: UIColor?, size: CGSize = CGSizeMake(1, 1)) {
        
        guard let color = color else {
            return nil
        }
        
        var rect = CGRectZero
        rect.size = size
        
        UIGraphicsBeginImageContext(size);
        let path = UIBezierPath(rect: rect)
        color.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        guard let cg = image.CGImage else {
            return nil
        }
        
        self.init(CGImage: cg)
    }
    
    
    convenience init?(image: UIImage, size: CGSize) {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cg = newImage.CGImage else {
            return nil
        }
        
        self.init(CGImage: cg)
    }
    
    /**
     Fill Image with Tint Color
     
     :param: tintColor
     
     :returns: UIImage with Tint Color
     */
    func imageWithTint(tintColor: UIColor) -> UIImage {
        
        let rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        
        drawInRect(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetBlendMode(ctx, .SourceIn)
        
        CGContextSetFillColorWithColor(ctx, tintColor.CGColor)
        CGContextFillRect(ctx, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func changeImageColor(color: UIColor?) -> UIImage {
        
        guard let color = color else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, .Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        
        CGContextClipToMask(context, rect, self.CGImage)
        
        color.setFill()
        
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func changeImageAlpha(alpha: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext()
        let area = CGRectMake(0, 0, self.size.width, self.size.height)
        
        CGContextScaleCTM(ctx, 1, -1)
        CGContextTranslateCTM(ctx, 0, -area.size.height)
        
        CGContextSetBlendMode(ctx, .Multiply)
        
        CGContextSetAlpha(ctx, alpha)
        
        CGContextDrawImage(ctx, area, self.CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageWithCornerRadius(radius: CGFloat) -> UIImage {
        
        let imageLayer = CALayer()
        imageLayer.frame = CGRectMake(0, 0, self.size.width, self.size.height)
        imageLayer.contents = self.CGImage
        
        imageLayer.masksToBounds = true
        imageLayer.cornerRadius = radius
        
        UIGraphicsBeginImageContext(self.size)
        
        if let context = UIGraphicsGetCurrentContext() {
            imageLayer.renderInContext(context)
        }
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    var base64EncodedString: String? {
        return self.base64EncodedString()
    }
    
    func base64EncodedString(jpeg: Bool = false, compression: CGFloat = 1) -> String? {
        
        if jpeg {
            return UIImageJPEGRepresentation(self, compression)?.base64EncodedStringWithOptions([])
        }
        
        return UIImagePNGRepresentation(self)?.base64EncodedStringWithOptions([])
    }
    
    convenience init?(base64EncodedString: String) {
        
        guard let decodedData = NSData(base64EncodedString: base64EncodedString, options: []) else {
            return nil
        }
        
        self.init(data: decodedData)
    }
    
    
    func fixOrientation() -> UIImage
    {
        // No-op if the orientation is already correct
        if (self.imageOrientation == .Up) {
            return self
        }
        
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransformIdentity
        
        switch (self.imageOrientation)
        {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
        case .Up, .UpMirrored:
            break
        }
        
        switch (self.imageOrientation)
        {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .Up, .Down, .Left, .Right:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage).rawValue)
        CGContextConcatCTM(ctx, transform)
        switch (self.imageOrientation)
        {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
            break
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage)
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        if let cgimg = CGBitmapContextCreateImage(ctx) {
            return UIImage(CGImage: cgimg)
        }
        return self
    }
    
    func resizedImagedForBackground() -> UIImage?
    {
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        let heightMultiplier = screenHeight / self.size.height
        
        var newWidth = self.size.width * heightMultiplier
        
        var scale = UIScreen.mainScreen().scale
        
        let newHeight = screenHeight / scale
        newWidth /= scale
        
        guard let image = self.resizeImage(CGSizeMake(newWidth, newHeight)) else {
            return nil
        }
        
        let widthMultiplier = screenWidth / image.size.width
        
        newWidth = image.size.width * widthMultiplier
        
        let x = (image.size.width - newWidth) / 2.0
        
        var rect = CGRectMake(x, 0, newWidth, screenHeight)
        
        scale = image.scale
        if (scale > 1.0)
        {
            rect = CGRectMake(rect.origin.x * scale,
                rect.origin.y * scale,
                rect.size.width * scale,
                rect.size.height * scale)
        }
        
        guard let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect) else {
            return nil
        }
        
        return UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    }
    
    
    
    func resizeImage(newSize: CGSize) -> UIImage? {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let imageRef = self.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        // Get the resized image from the context and a UIImage
        let newImageRef = CGBitmapContextCreateImage(context)
        UIGraphicsEndImageContext()
        
        guard let ref = newImageRef else {
            return nil
        }
        
        return UIImage(CGImage: ref)
    }
    
    class func screenshotImage() -> UIImage?
    {
        return UIApplication.sharedApplication().keyWindow?.asImage
    }
    
    func flipImageHorizontally() -> UIImage? {
        
        if let cg = self.CGImage {
            return UIImage(CGImage: cg, scale: 1.0, orientation: .DownMirrored)
        }
        
        return nil
    }
    
    var averageColor: UIColor? {
        
        let rgba = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        
        guard let  colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB() else {
            return nil
        }
        
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        guard let context: CGContextRef = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, info.rawValue) else {
            return nil
        }
        
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage)
        
        if rgba[3] > 0 {
            
            let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
            let multiplier: CGFloat = alpha / 255.0
            
            return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
            
        } else {
            
            return UIColor(red: CGFloat(rgba[0]) / 255.0, green: CGFloat(rgba[1]) / 255.0, blue: CGFloat(rgba[2]) / 255.0, alpha: CGFloat(rgba[3]) / 255.0)
        }
    }
    
    func imageWithShadow() -> UIImage?
    {
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let shadowContext = CGBitmapContextCreate(nil, Int(self.size.width) + 10, Int(self.size.height) + 10, CGImageGetBitsPerComponent(self.CGImage), 0,
            colourSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextSetShadowWithColor(shadowContext, CGSizeMake(5, -5), 5, UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor)
        CGContextDrawImage(shadowContext, CGRectMake(0, 10, self.size.width, self.size.height), self.CGImage)
        
        guard let shadowedCGImage = CGBitmapContextCreateImage(shadowContext) else {
            return nil
        }
        
        let shadowedImage = UIImage(CGImage:shadowedCGImage)
        
        return shadowedImage
    }
    
    /*
    
    - (void)mainColorInImage:(void(^)(UIColor *mainColor))completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^()
    {
    UIColor *color = [[self mainColorsInImageWithDetail:3 removeBlack:YES removeWhite:YES] firstObject]
    completion(color)
    })
    }
    
    - (UIColor *)mainColorInImage {
    
    return [[self mainColorsInImageWithDetail:0 removeBlack:YES removeWhite:YES] firstObject]
    }
    
    - (NSArray *)mainColorsInImageWithDetail:(int)detail removeBlack:(BOOL)removeBlack removeWhite:(BOOL)removeWhite {
    
    
    @autoreleasepool {
    //1. determine detail vars (0==low,1==default,2==high)
    //default detail
    float dimension = 10
    float flexibility = 1
    float range = 60
    
    //low detail
    if (detail==0){
    dimension = 4
    flexibility = 1
    range = 100
    
    } else if (detail==2){
    dimension = 50
    flexibility = 1
    range = 40
    }
    //high detail (patience!)
    else if (detail==3){
    dimension = 100
    flexibility = 1
    range = 20
    }
    
    //2. determine the colours in the image
    NSMutableArray * colours = [NSMutableArray new]
    CGImageRef imageRef = [self CGImage]
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB()
    unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char))
    NSUInteger bytesPerPixel = 4
    NSUInteger bytesPerRow = bytesPerPixel * dimension
    NSUInteger bitsPerComponent = 8
    CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big)
    CGColorSpaceRelease(colorSpace)
    CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef)
    CGContextRelease(context)
    
    float x = 0
    float y = 0
    for (int n = 0 n<(dimension*dimension) n++){
    
    int index = (bytesPerRow * y) + x * bytesPerPixel
    int red   = rawData[index]
    int green = rawData[index + 1]
    int blue  = rawData[index + 2]
    int alpha = rawData[index + 3]
    NSArray * a = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil]
    [colours addObject:a]
    
    y++
    if (y==dimension){
    y=0
    x++
    }
    }
    free(rawData)
    
    //3. add some colour flexibility (adds more colours either side of the colours in the image)
    NSArray * copyColours = [NSArray arrayWithArray:colours]
    NSMutableArray * flexibleColours = [NSMutableArray new]
    
    float flexFactor = flexibility * 2 + 1
    float factor = flexFactor * flexFactor * 3 //(r,g,b) == *3
    for (int n = 0 n<(dimension * dimension) n++){
    
    NSArray * pixelColours = copyColours[n]
    NSMutableArray * reds = [NSMutableArray new]
    NSMutableArray * greens = [NSMutableArray new]
    NSMutableArray * blues = [NSMutableArray new]
    
    for (int p = 0 p<3 p++){
    
    NSString * rgbStr = pixelColours[p]
    int rgb = [rgbStr intValue]
    
    for (int f = -flexibility f<flexibility+1 f++){
    int newRGB = rgb+f
    if (newRGB<0){
    newRGB = 0
    }
    if (p==0){
    [reds addObject:[NSString stringWithFormat:@"%i",newRGB]]
    } else if (p==1){
    [greens addObject:[NSString stringWithFormat:@"%i",newRGB]]
    } else if (p==2){
    [blues addObject:[NSString stringWithFormat:@"%i",newRGB]]
    }
    }
    }
    
    int r = 0
    int g = 0
    int b = 0
    for (int k = 0 k<factor k++){
    
    int red = [reds[r] intValue]
    int green = [greens[g] intValue]
    int blue = [blues[b] intValue]
    
    NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue]
    [flexibleColours addObject:rgbString]
    
    b++
    if (b==flexFactor){ b=0 g++ }
    if (g==flexFactor){ g=0 r++ }
    }
    }
    
    //4. distinguish the colours
    //orders the flexible colours by their occurrence
    //then keeps them if they are sufficiently disimilar
    
    NSMutableDictionary * colourCounter = [NSMutableDictionary new]
    
    //count the occurences in the array
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours]
    for (NSString *item in countedSet) {
    NSUInteger count = [countedSet countForObject:item]
    [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item]
    }
    
    //sort keys highest occurrence to lowest
    NSArray *orderedKeys = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
    return [obj2 compare:obj1]
    }]
    
    //checks if the colour is similar to another one already included
    NSMutableArray * ranges = [NSMutableArray new]
    for (NSString * key in orderedKeys){
    NSArray * rgb = [key componentsSeparatedByString:@","]
    int r = [rgb[0] intValue]
    int g = [rgb[1] intValue]
    int b = [rgb[2] intValue]
    bool exclude = false
    for (NSString * ranged_key in ranges){
    NSArray * ranged_rgb = [ranged_key componentsSeparatedByString:@","]
    
    int ranged_r = [ranged_rgb[0] intValue]
    int ranged_g = [ranged_rgb[1] intValue]
    int ranged_b = [ranged_rgb[2] intValue]
    
    if (r>= ranged_r-range && r<= ranged_r+range){
    if (g>= ranged_g-range && g<= ranged_g+range){
    if (b>= ranged_b-range && b<= ranged_b+range){
    exclude = true
    }
    }
    }
    }
    
    if (!exclude){ [ranges addObject:key] }
    }
    
    //return ranges array here if you just want the ordered colours high to low
    NSMutableArray * colourArray = [NSMutableArray new]
    for (NSString * key in ranges){
    NSArray * rgb = [key componentsSeparatedByString:@","]
    float r = [rgb[0] floatValue]
    float g = [rgb[1] floatValue]
    float b = [rgb[2] floatValue]
    if (removeBlack && !r && !g && !b) {
    continue
    }
    if (removeWhite && r>240 && g>240 && b>240) {
    continue
    }
    UIColor * colour = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
    [colourArray addObject:colour]
    }
    
    //if you just want an array of images of most common to least, return here
    return colourArray
    
    }
    }
    */
}
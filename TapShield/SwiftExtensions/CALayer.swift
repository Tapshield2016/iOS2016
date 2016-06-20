//
//  File.swift
//  Pods
//
//  Created by Adam J Share on 11/19/15.
//
//

import Foundation
import UIKit

public extension CALayer {
    
    func addLineLayer(pointA: CGPoint, pointB: CGPoint) -> CAShapeLayer {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.moveToPoint(pointA)
        linePath.addLineToPoint(pointB)
        line.path = linePath.CGPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.addSublayer(line)
        return line
    }
}
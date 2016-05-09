//
//  CLLocationDirection.swift
//  Pods
//
//  Created by Adam J Share on 11/10/15.
//
//

import Foundation
import UIKit
import CoreLocation

public extension CLLocationDirection {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}
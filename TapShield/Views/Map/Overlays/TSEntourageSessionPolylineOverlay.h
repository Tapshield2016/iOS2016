//
//  TSEntourageSessionPolyline.h
//  TapShield
//
//  Created by Adam Share on 11/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TSEntourageSessionPolylineOverlay : MKPolyline

- (MKPolylineRenderer *)renderer;

@end


@interface TSEntourageSessionPolylineRenderer : MKPolylineRenderer

@property (assign) BOOL selectedRoute;
@property (assign) BOOL history;

@end
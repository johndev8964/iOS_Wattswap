//
//   MKMapView+ZoomLevel.h
//  Wattswap
//
//  Created by MY on 8/10/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#ifndef Wattswap__MKMapView_ZoomLevel_h
#define Wattswap__MKMapView_ZoomLevel_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end

#endif

//
//  MapPinAnnotation.h
//  DropAP
//
//  Created by Gemtek_Phineas_Huang on 11/25/15.
//  Copyright © 2015 Browan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomMapOverlay.h"

#define DEFAULT_RADIUS 100

@interface MapPinAnnotationObj:NSObject

@property(nonatomic, retain) MKPinAnnotationView *annotationView;
@property(nonatomic, retain) MKCircle *circle;
@property(nonatomic, retain) CustomMKCircleOverlay *circleView;
@property(nonatomic, retain) MKPointAnnotation *point;

@property(nonatomic)  MKMapPoint lastPoint;
@property(nonatomic) CLLocationCoordinate2D droppedAt;
@property(nonatomic) bool panEnabled;
@property(nonatomic) double oldoffset;
@property(nonatomic) double setRadius;
@property(nonatomic) NSInteger tag;

@end

//
//  MapPinAnnotation.m
//  DropAP
//
//  Created by Gemtek_Phineas_Huang on 11/25/15.
//  Copyright © 2015 Browan. All rights reserved.
//

#import "MapPinAnnotationObj.h"

@implementation MapPinAnnotationObj

- (id) init {
    if ( self = [super init] ) {
        self.panEnabled = YES;
        self.setRadius = DEFAULT_RADIUS;
    }
    return self;
}

@end

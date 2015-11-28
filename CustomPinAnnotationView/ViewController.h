//
//  ViewController.h
//  CustomPinAnnotationView
//
//  Created by Phineas_Huang on 11/28/15.
//  Copyright © 2015 SunXiaoShan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPinAnnotationObj.h"
#import "BaseViewController.h"

@interface ViewController : BaseViewController<MKMapViewDelegate, CustomMapDelegate, UIImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>


@end


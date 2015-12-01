//
//  BaseViewController.h
//  CustomPinAnnotationView
//
//  Created by Phineas_Huang on 11/28/15.
//  Copyright © 2015 SunXiaoShan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define TOAST_INTERVAL  3   //seconds

@interface BaseViewController : UIViewController

- (void) showToast:(NSString *) text;

- (void) showOkDialog:(NSString *)message tag:(int)tag;
- (void) showConfirmDialog:(NSString *)message tag:(int)tag;

@end

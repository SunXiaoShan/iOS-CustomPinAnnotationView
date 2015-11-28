//
//  BaseViewController.m
//  CustomPinAnnotationView
//
//  Created by Phineas_Huang on 11/28/15.
//  Copyright © 2015 SunXiaoShan. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showToast:(NSString *) text {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //    HUD.labelText = text;         // only single line
    HUD.detailsLabelText = text;    // allow multi line
    HUD.mode = MBProgressHUDModeText;
    HUD.yOffset = 160;
    [HUD showWhileExecuting:@selector(threadSleep:) onTarget:self withObject:HUD animated:YES];
}

- (void) threadSleep:(MBProgressHUD *)HUD {
    sleep(TOAST_INTERVAL);
    dispatch_async(dispatch_get_main_queue(), ^{
        [HUD removeFromSuperview];
    });
}

@end

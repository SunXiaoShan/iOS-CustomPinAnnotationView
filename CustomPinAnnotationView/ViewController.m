//
//  ViewController.m
//  CustomPinAnnotationView
//
//  Created by Phineas_Huang on 11/28/15.
//  Copyright © 2015 SunXiaoShan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableArray *arrAnchorPoint;
    UIButton *mBeSelectAnchorIcon;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    MKCoordinateRegion region;
    
    region.center.latitude = 23.58;
    region.center.longitude = 120.58;
    
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    [_mapView setRegion:region animated:YES];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    _mapView.rotateEnabled = NO;
    
    [self showAnchorPoint];
}

#pragma mark - map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    int index = -1;
    for (int i=0; i<[arrAnchorPoint count]; i++) {
        if ([annotation isEqual:arrAnchorPoint[i]]) {
            index = i+1;
            break;
        }
    }
    
    if (index == -1) {
        return nil;
    }
    
    static NSString * PinIdentifier = @"Pin";
    CGRect frame = CGRectMake(0, 0, 50, 50);
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        annotationView.frame = frame;
    }
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"test0%d.jpg", index]];
    UIButton *headShot = [[UIButton alloc] initWithFrame:frame];
    [headShot setImage:img forState:UIControlStateNormal];
    [headShot addTarget:self action:@selector(switchHeadShot:) forControlEvents:UIControlEventTouchUpInside];
    headShot.layer.cornerRadius = headShot.frame.size.height/2;
    headShot.layer.masksToBounds = YES;
    headShot.layer.borderColor = [UIColor colorWithRed:148/255. green:79/255. blue:216/255. alpha:1.0].CGColor;
    headShot.layer.borderWidth = 2;
    headShot.tag = index;
    annotationView.tag = index;
    [annotationView addSubview:headShot];
    
    return annotationView;
}

#pragma mark - button action

- (void) switchHeadShot:(id)sender {
    
    mBeSelectAnchorIcon = sender;
    
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:NO completion:nil];
}

#pragma mark - picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *oldImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    oldImage = [self scaleAndRotateImage:oldImage];
    CGRect cropRect = [info[@"UIImagePickerControllerCropRect"] CGRectValue];
    CGImageRef imageRef = CGImageCreateWithImageInRect([oldImage CGImage], cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSString *fullPath = [self getImagePath:image];
    [mBeSelectAnchorIcon setImage:image forState:UIControlStateNormal];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - other

- (void) showAnchorPoint {
    
    CLLocation *LAX = [[CLLocation alloc] initWithLatitude:23.9424955
                                                 longitude:118.4080684];
    CLLocation *JFK = [[CLLocation alloc] initWithLatitude:40.6397511
                                                 longitude:134.4080684];
    CLLocation *JFK01 = [[CLLocation alloc] initWithLatitude:41.6397511
                                                   longitude:135.4080684];
    CLLocation *JFK02 = [[CLLocation alloc] initWithLatitude:46.6397511
                                                   longitude:137.4080684];
    
    CLLocationCoordinate2D coordinates[4] = {
        LAX.coordinate,
        JFK.coordinate,
        JFK01.coordinate,
        JFK02.coordinate
    };
    
    arrAnchorPoint = [[NSMutableArray alloc] init];
    for (int i=0; i<4; i++) {
        CLLocationCoordinate2D coordinate = coordinates[i];
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = coordinate;
        [arrAnchorPoint addObject:point];
    }
    [_mapView showAnnotations:arrAnchorPoint animated:YES];
}

- (NSString *) getImagePath:(UIImage *)image {
    if (!image) {
        return @"";
    }
    
    NSString *imageName = [NSString stringWithFormat:@"test.png"];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:fullPath atomically:YES];
    return fullPath;
}

- (UIImage *) scaleAndRotateImage: (UIImage *)image
{
    int kMaxResolution = 3000; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),      CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end

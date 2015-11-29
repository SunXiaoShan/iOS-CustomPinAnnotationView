//
//  ViewController.m
//  CustomPinAnnotationView
//
//  Created by Phineas_Huang on 11/28/15.
//  Copyright © 2015 SunXiaoShan. All rights reserved.
//

#import "ViewController.h"

#define DEFAULT_RADIUS 100
#define PIN_TAG 100

@interface ViewController ()
{
    // Anchor point
    NSMutableArray *arrAnchorPoint;
    UIButton *mBeSelectAnchorIcon;
    
    // drop point
    NSMutableArray *mPinArr;
    MapPinAnnotationObj *dropPin;
    MapPinAnnotationObj *resizePin;
    MapPinAnnotationObj *addPin;
    NSString *distance;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

double const circleRadius = 0;

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
    
    // for Anchor point
    [self showAnchorPoint];
    
    // for drop point
    [self setupDropPoint];
}

#pragma mark - map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    int index = -1;
    for (int i=0; i<[arrAnchorPoint count]; i++) {
        if ([annotation isEqual:arrAnchorPoint[i]]) {
            index = i+1;
            return [self mapView4Anchor:mapView viewForAnnotation:annotation index:index];
        }
    }
    
    return [self mapView4Drop:mapView viewForAnnotation:annotation];
}

- (MKAnnotationView *) mapView4Anchor:(MKMapView *)mapView
                    viewForAnnotation:(id <MKAnnotation>)annotation
                                index:(int)index {
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

- (MKAnnotationView *) mapView4Drop:(MKMapView *)mapView
                    viewForAnnotation:(id <MKAnnotation>)annotation {
    
    NSInteger tag = [self getAnnotationViewTag:annotation];
    MapPinAnnotationObj *pin = [self getPinAnnotationViewByAnnotation4CreateView:annotation];
    if (tag == -1 || !pin) {
        NSLog(@"no annotation");
        return nil;
    }
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    pin.annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    [pin.annotationView setDraggable:YES];
    pin.annotationView.pinTintColor = [UIColor purpleColor];
    
    [pin.annotationView setSelected:YES animated:YES];
    return [pin.annotationView init];
}

- (void) mapView:(MKMapView *)mapView
  annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
    fromOldState:(MKAnnotationViewDragState)oldState {
    
    if(newState == MKAnnotationViewDragStateStarting){
        dropPin = [self getPinAnnotationViewByAnnotationView:annotationView];
        dropPin.panEnabled = YES;
    }
    if (newState == MKAnnotationViewDragStateEnding) {
        dropPin.droppedAt = annotationView.annotation.coordinate;
        [self addCircle:dropPin];
        dropPin = nil;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if (dropPin == nil && addPin == nil) {
        return nil;
    }
    
    MapPinAnnotationObj *pin = dropPin?dropPin:addPin;
    
    pin.circleView = [[CustomMKCircleOverlay alloc] initWithCircle:overlay];
    pin.circleView.fillColor = [UIColor redColor];
    pin.circleView.delegate = self;
    
    return pin.circleView;
}

#pragma mark - CustomMKCircleOverlay delegate

-(void)onRadiusChange:(CustomMKCircleOverlay *)circleView radius:(CGFloat)radius{
    NSLog(@"on radius change: %f", radius);
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

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *oldImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    oldImage = [self scaleAndRotateImage:oldImage];
    CGRect cropRect = [info[@"UIImagePickerControllerCropRect"] CGRectValue];
    CGImageRef imageRef = CGImageCreateWithImageInRect([oldImage CGImage], cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSString *fullPath = [self getImagePath:image];
    NSLog(@"path : %@", fullPath);
    [mBeSelectAnchorIcon setImage:image forState:UIControlStateNormal];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Anchor : other

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

#pragma mark - drop : other

- (void) setupDropPoint {
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tapRecognizer];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        
        if (resizePin) {
            return;
        }
        
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self.mapView];
        
        CLLocationCoordinate2D coord = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
        MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
        
        for (MapPinAnnotationObj *view in mPinArr) {
            
            MKMapRect mapRect = [view.circleView circlebounds];
            
            double xPath = mapPoint.x - (mapRect.origin.x - (mapRect.size.width/2));
            double yPath = mapPoint.y - (mapRect.origin.y - (mapRect.size.height/2));
            
            if (xPath >= 0 && yPath >= 0 && xPath < mapRect.size.width && yPath < mapRect.size.height) {
                NSLog(@"Disable Map Panning");
                resizePin = view;
                break;
            }
        }
        
        if (resizePin) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mapView.scrollEnabled = NO;
                resizePin.panEnabled = NO;
                resizePin.oldoffset = [resizePin.circleView getCircleRadius];
            });
            
        } else {
            self.mapView.scrollEnabled = YES;
        }
        resizePin.lastPoint = mapPoint;
    };
    
    tapInterceptor.touchesMovedCallback = ^(NSSet * touches, UIEvent * event) {
        
        if (resizePin && !resizePin.panEnabled && [event allTouches].count == 1) {
            UITouch *touch = [touches anyObject];
            CGPoint p = [touch locationInView:self.mapView];
            
            CLLocationCoordinate2D coord = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
            MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
            
            MKMapRect mRect = self.mapView.visibleMapRect;
            MKMapRect circleRect = [resizePin.circleView circlebounds];
            
            /* Check if the map needs to zoom */
            if (circleRect.size.width > mRect.size.width *.55) {
                MKCoordinateRegion region;
                //Set Zoom level using Span
                MKCoordinateSpan span;
                region.center = resizePin.droppedAt;
                span.latitudeDelta = self.mapView.region.span.latitudeDelta * 2.0;
                span.longitudeDelta = self.mapView.region.span.longitudeDelta * 2.0;
                region.span = span;
                [_mapView setRegion:region animated:TRUE];
            }
            if (circleRect.size.width < mRect.size.width *.25) {
                MKCoordinateRegion region;
                //Set Zoom level using Span
                MKCoordinateSpan span;
                region.center = resizePin.droppedAt;
                span.latitudeDelta = _mapView.region.span.latitudeDelta / 3.0002;
                span.longitudeDelta = _mapView.region.span.longitudeDelta / 3.0002;
                region.span = span;
                [_mapView setRegion:region animated:TRUE];
            }
            
            double meterDistance = (mapPoint.x - resizePin.lastPoint.x) / MKMapPointsPerMeterAtLatitude(self.mapView.centerCoordinate.latitude)+ resizePin.oldoffset;
            if (meterDistance > 0) {
                [resizePin.circleView setCircleRadius:meterDistance];
            }
            resizePin.setRadius = resizePin.circleView.getCircleRadius;
            
            if (resizePin.setRadius > 1000) {
                distance = [NSString stringWithFormat:@"%.02f km", resizePin.setRadius / 1000];
            } else {
                distance = [NSString stringWithFormat:@"%.f m", resizePin.setRadius];
            }
            NSLog(@"move distance:%@", distance);
        }
    };
    
    tapInterceptor.touchesEndedCallback = ^(NSSet * touches, UIEvent * event) {
        
        resizePin.panEnabled = YES;
        
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.userInteractionEnabled = YES;
        
        if (resizePin) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showToast:distance];
            });
        }
        
        resizePin = nil;
    };
    
    [self.mapView addGestureRecognizer:tapInterceptor];
}

- (void) foundTap:(UITapGestureRecognizer *)recognizer
{
    if (!mPinArr) {
        mPinArr = [[NSMutableArray alloc] init];
    }
    
    CGPoint point = [recognizer locationInView:self.mapView];
    CGRect frameMap = _mapView.frame;
    point.y += frameMap.origin.y;
    point.x += frameMap.origin.x;
    
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = tapPoint;
    
    MapPinAnnotationObj *pin = [[MapPinAnnotationObj alloc] init];
    pin.droppedAt = tapPoint;
    [pin setTag:[mPinArr count] + PIN_TAG];
    [mPinArr addObject:pin];
    addPin = pin;
    [self addCircle:pin];
    addPin = nil;
}

- (void) addCircle:(MapPinAnnotationObj *)pin {
    
    if (pin.circle) {
        [self.mapView removeOverlay:pin.circle];
    }
    pin.circle = [MKCircle circleWithCenterCoordinate:pin.droppedAt radius:circleRadius];
    
    [self.mapView addOverlay: pin.circle];
    
    [pin.circleView setCircleRadius:pin.setRadius];
    pin.circleView.tag = pin.tag;
    
    if (pin.point == nil) {
        pin.point = [[MKPointAnnotation alloc] init];
        pin.point.coordinate = pin.droppedAt;
        [self.mapView addAnnotation:pin.point];
    }
}

- (NSInteger) getAnnotationViewTag:(id <MKAnnotation>)annotation
{
    for (MapPinAnnotationObj *view in mPinArr) {
        if ([view.point isEqual:annotation]) {
            return view.tag;
        }
    }
    return -1;
}

- (MapPinAnnotationObj *) getPinAnnotationViewByAnnotation4CreateView:(id <MKAnnotation>)annotation
{
    for (MapPinAnnotationObj *view in mPinArr) {
        if ([view.point isEqual:annotation]) {
            return view;
        }
    }
    return nil;
}

- (MapPinAnnotationObj *) getPinAnnotationViewByAnnotationView:(MKAnnotationView *)annotationView
{
    for (MapPinAnnotationObj *view in mPinArr) {
        if ([view.point isEqual:annotationView.annotation]) {
            return view;
        } else if (view.tag == annotationView.tag) {
            return view;
        }
    }
    return nil;
}

@end

//
//  LocationViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "LocationViewController.h"
#import "LegalViewController.h"
#import "MapPoint.h"
#import "SliderView.h"
#import "TutorialView.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface LocationViewController () <MKMapViewDelegate, SliderDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
{
    BOOL progress;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *setButon;
@property (nonatomic, strong) UIView *setView;
@property (nonatomic, strong) UIView *confirmView;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, assign) BOOL updateUserLocation;
@property (nonatomic, assign) CLLocationCoordinate2D targetLocation;
@property (nonatomic, strong) SliderView *radiusSlider;
@property (nonatomic, strong) UIView *radiusView;
@property (nonatomic, strong) UIImageView *crossImageView;
@property (nonatomic, strong) UIButton *myLocButton;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *infoPopView;
@property (nonatomic, strong) Area *area;
@property (nonatomic, copy) NSString *placeName;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) BOOL userInputText;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, strong) TutorialView *tutorialView;

@end

@implementation LocationViewController

- (id)init
{
    self = [super init];
    if (self) {
        _updateUserLocation = YES;
    }
    return self;
}

- (id)initWithSettingType:(SettingType)settingType areaModal:(Area *)area
{
    self = [self init];
    if (self) {
        // Custom initialization
        if (settingType == SettingTypeInit || settingType == SettingTypeAdd) {
            _updateUserLocation = YES;
        } else {
            _updateUserLocation = NO;
        }
        _settingType = settingType;
        _area = area;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 84.0, SCREEN_WIDTH, SCREEN_HEIGHT - 84.0 - 10.0)];
    [self.mapView setDelegate:self];
    if ([self.mapView respondsToSelector:@selector(setRotateEnabled:)]) {
        [self.mapView setRotateEnabled:NO];
    }
    if ([self.mapView respondsToSelector:@selector(setPitchEnabled:)]) {
        [self.mapView setPitchEnabled:NO];
    }
    [self.mapView setHidden:YES];
    [self.view addSubview:self.mapView];
    
    self.radiusView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.radiusView setCenter:self.mapView.center];
    [self.radiusView setBackgroundColor:[UIColor colorWithRed:0.83 green:0.93 blue:1 alpha:0.8]];
    [self.radiusView.layer setBorderWidth:1.0];
    [self.radiusView.layer setBorderColor:[UIColor colorWithRed:0.41 green:0.65 blue:0.95 alpha:1].CGColor];
    [self.radiusView setUserInteractionEnabled:NO];
    [self.radiusView setAlpha:0];
    [self.view addSubview:self.radiusView];
    
    double radius = [self.area.radius doubleValue];
    if (radius > 0) {
        [self setRadius:radius];
    } else {
        [self setRadius:500.0];
    }
    [self setLocationRadius:self.radius];
    if (self.settingType == SettingTypeInit) {
        [self.radiusView setHidden:YES];
    }

    UIImage *crossImage = [UIImage imageNamed:@"map_cross"];
    self.crossImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(crossImage)];
    [self.crossImageView setCenter:self.mapView.center];
    [self.crossImageView setImage:crossImage];
    [self.crossImageView setAlpha:0];
    [self.view addSubview:self.crossImageView];
    
    UIImage *myLocImage = [UIImage imageNamed:@"my_location_button"];
    self.myLocButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.myLocButton setFrame:CGRectOffsetFromImage(myLocImage, 270.0, SCREEN_HEIGHT - 130.0)];
    [self.myLocButton setImage:myLocImage forState:UIControlStateNormal];
    [self.myLocButton addTarget:self action:@selector(myLocButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.myLocButton setAlpha:0];
    [self.view addSubview:self.myLocButton];

    UIImage *headerImage = nil;
    switch (self.settingType) {
        case SettingTypeInit:
            headerImage = [UIImage imageNamed:@"location_header"];
            break;
        case SettingTypeEdit:
            headerImage = [UIImage imageNamed:@"location_reset_header"];
            break;
        case SettingTypeAdd:
        case SettingTypeReEdit:
            headerImage = [UIImage imageNamed:@"setting_header"];
            break;
        default:
            break;
    }
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(headerImage)];
    [headerImageView setImage:headerImage];
    [self.view addSubview:headerImageView];
    
    UIImage *bgImage = [UIImage imageNamed:@"location_bg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(bgImage, 0, headerImageView.bottom)];
    [bgImageView setImage:bgImage];
    [self.view addSubview:bgImageView];
    
    switch (self.settingType) {
        case SettingTypeInit:
            [self configBackButton];
            break;
        case SettingTypeAdd:
        case SettingTypeReEdit:
            [self configDismissButton];
            break;
        case SettingTypeEdit:
            [self configCancelButton];
            break;
        default:
            break;
    }
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(45.0, 91.0, 250.0, 42.0)];
    [self.textField setTextColor:[UIColor whiteColor]];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.textField setDelegate:self];
    [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.textField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"検索または住所" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}]];
    [self.view addSubview:self.textField];
    
    UIImage *clearImage = [UIImage imageNamed:@"x_close"];
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setFrame:CGRectFromImage(clearImage)];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.textField setRightView:clearButton];
    [self.textField setRightViewMode:UITextFieldViewModeWhileEditing];
    
    if (self.settingType == SettingTypeInit) {
        if (!self.tutorialView) {
            self.tutorialView = [TutorialView showWithTutorialType:TutorialTypeSetting];
        }
        [self.tutorialView setAlpha:0.0];
        [UIView animateWithDuration:0.3 animations:^{
            [self.tutorialView setAlpha:1.0];
        }];
    } else {
        [self showMapView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialDidFinishedNotification:) name:TutorialSettingDidFinishedNotification object:nil];
}

- (void)handleTutorialDidFinishedNotification:(NSNotification *)notification
{
    [self showMapView];
}

- (void)showInfoPopView
{
    self.infoPopView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.infoPopView];
    
    UIImage *popImage = [UIImage imageNamed:@"location_setting_pop"];
    UIImageView *popImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(popImage, (self.infoPopView.width - popImage.size.width) / 2, (self.infoPopView.height - popImage.size.height) / 2)];
    [popImageView setImage:popImage];
    [popImageView setUserInteractionEnabled:YES];
    [self.infoPopView addSubview:popImageView];
    
    UIImage *closeImage = [UIImage imageNamed:@"ok"];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake((popImageView.width - closeImage.size.width) / 2, 400.0, closeImage.size.width, closeImage.size.height)];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [popImageView addSubview:closeButton];
}

- (void)setLocationRadius:(CGFloat)radius
{
    self.targetLocation = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.view];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.targetLocation.latitude, self.targetLocation.longitude);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, radius * 2, radius * 2);
    CGRect radiusRect = [self.mapView convertRegion:coordinateRegion toRectToView:self.view];

    CGFloat width = radiusRect.size.width;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.radiusView.layer setCornerRadius:width / 2];
        [self.radiusView setFrame:radiusRect];
    }];
}

- (void)showRadiusSlider
{
    if (!self.radiusSlider) {
        self.radiusSlider = [[SliderView alloc] initWithFrame:CGRectMake(0, 0, 37.0, 192.0)];
        [self.radiusSlider setDelegate:self];
        [self.radiusSlider setCenter:CGPointMake(10.0 + self.radiusSlider.width / 2, self.mapView.center.y)];
        [self.radiusSlider setMinValue:50];
        [self.radiusSlider setMaxValue:500];
        [self.radiusSlider setValue:self.radius];
        [self.view insertSubview:self.radiusSlider aboveSubview:self.radiusView];
    }
    [self.radiusSlider setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - SliderViewDelegate

- (void)sliderView:(SliderView *)sliderView stoppedAtValue:(CGFloat)value
{
    [self setRadius:value];
    [self setLocationRadius:value];
}

- (void)sliderView:(SliderView *)sliderView valueDidChanged:(CGFloat)value
{
    [self setRadius:value];
    [self setLocationRadius:value];
}

- (void)showSetButton
{
    if (!self.setButon) {
        UIImage *setImage = [UIImage imageNamed:@"location_setting"];
        self.setButon = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.setButon setFrame:CGRectOffsetFromImage(setImage, (SCREEN_WIDTH - setImage.size.width) / 2, SCREEN_HEIGHT - 60.0)];
        [self.setButon setImage:setImage forState:UIControlStateNormal];
        [self.setButon addTarget:self action:@selector(setButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:self.setButon aboveSubview:self.radiusView];
    }
    [self.setButon setAlpha:0.0];
    [self.setButon setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.setButon setAlpha:1.0];
        [self.setView setAlpha:0.0];
        [self.confirmView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.setView setHidden:YES];
        [self.confirmView setHidden:YES];
    }];
    [self.radiusSlider setHidden:YES];
    [self.textField setEnabled:YES];
    [self.myLocButton setHidden:NO];
    [self.mapView setUserInteractionEnabled:YES];
}

- (void)showSetView
{
    if (!self.setView) {
        self.setView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 88.0 - 10.0, SCREEN_WIDTH, 88.0)];
        [self.view insertSubview:self.setView aboveSubview:self.radiusView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.setView.bounds];
        [bgView setBackgroundColor:[UIColor colorWithRed:0.27 green:0.48 blue:0.63 alpha:0.9]];
        [self.setView addSubview:bgView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.setView.width, 36.0)];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setFont:[UIFont systemFontOfSize:13.0]];
        [textLabel setText:@"中心が勤務地となるように地図を動かして下さい。"];
        [self.setView addSubview:textLabel];
        
        UIImage *setImage = [UIImage imageNamed:@"location_setting"];
        UIButton *setButon = [UIButton buttonWithType:UIButtonTypeCustom];
        [setButon setFrame:CGRectOffsetFromImage(setImage, (SCREEN_WIDTH - setImage.size.width) / 2, 36.0)];
        [setButon setImage:setImage forState:UIControlStateNormal];
        [setButon addTarget:self action:@selector(setButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.setView addSubview:setButon];
    }
    [self.setView setAlpha:0.0];
    [self.setView setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.setView setAlpha:1.0];
        [self.setButon setAlpha:0.0];
        [self.confirmView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.setButon setHidden:YES];
        [self.confirmView setHidden:YES];
    }];
}

- (void)showConfirmView
{
    if (!self.confirmView) {
        self.confirmView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 88.0 - 10.0, SCREEN_WIDTH, 88.0)];
        [self.view insertSubview:self.confirmView aboveSubview:self.radiusView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.confirmView.bounds];
        [bgView setBackgroundColor:[UIColor colorWithRed:0.27 green:0.48 blue:0.63 alpha:0.5]];
        [self.confirmView addSubview:bgView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.confirmView.width, 36.0)];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setFont:[UIFont systemFontOfSize:14.0]];
        [textLabel setText:@"この位置で決定してOKですか？"];
        [self.confirmView addSubview:textLabel];
        
        UIImage *cancelImage = [UIImage imageNamed:@"location_cancel"];
        UIButton *cancelButon = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButon setFrame:CGRectOffsetFromImage(cancelImage, 20.0, 36.0)];
        [cancelButon setImage:cancelImage forState:UIControlStateNormal];
        [cancelButon addTarget:self action:@selector(cancelButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmView addSubview:cancelButon];
        
        UIImage *confirmImage = [UIImage imageNamed:@"location_confirm"];
        UIButton *confirmButon = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButon setFrame:CGRectOffsetFromImage(confirmImage, 165.0, 36.0)];
        [confirmButon setImage:confirmImage forState:UIControlStateNormal];
        [confirmButon addTarget:self action:@selector(confirmButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmView addSubview:confirmButon];
    }
    [self.confirmView setAlpha:0.0];
    [self.confirmView setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.confirmView setAlpha:1.0];
        [self.setView setAlpha:0.0];
        [self.setButon setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.setView setHidden:YES];
        [self.setButon setHidden:YES];
    }];
    if (self.settingType != SettingTypeInit) {
        [self showRadiusSlider];
    }
    [self.textField setEnabled:NO];
    [self.myLocButton setHidden:YES];
    [self.mapView setUserInteractionEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)baseBackButtonDidClicked:(UIButton *)button
{
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    [self.view addSubview:self.tutorialView];
 
    [self.tutorialView setHidden:NO];
    [self.tutorialView setAlpha:0.0];
    [UIView animateWithDuration:0.3 animations:^{
        [self.tutorialView setAlpha:1.0];
    }];
}

- (void)baseDismissButtonDidClicked:(UIButton *)button
{
    if ([self.area.send_flag isEqualToString:@"0"] && self.settingType == SettingTypeAdd) {
        [self.area physicalDelete];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setButtonDidClicked:(UIButton *)button
{
    if (self.authorizationStatus == kCLAuthorizationStatusAuthorized) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        self.targetLocation = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self.view];
        DLog(@"Target Location: %f, %f", self.targetLocation.latitude, self.targetLocation.longitude);
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.targetLocation.latitude longitude:self.targetLocation.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error || placemarks.count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"ごめんなさい！その場所は設定できないんです。別な地名でレッツリトライ！もしかしたら、iPhoneの位置情報サービスで\"俺残\"が無効になっているかも。確認してね。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            } else {
                MKPlacemark *placemark = placemarks[0];
                [self setPlaceName:[self stringForPlacemark:placemark]];
                [self showConfirmView];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"おや！？位置情報サービスがオフになってますね…。 iPhoneの設定＞プライバシー＞位置情報サービスを「オン」に設定＞「俺残」を「オン」にしよう！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)closeButtonDidClicked:(UIButton *)button
{
    [UIView transitionWithView:self.infoPopView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:^(BOOL finished) {
        [self showMapView];
    }];
    [self.infoPopView removeFromSuperview];
}

- (void)showMapView
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.hidden = NO;
    self.mapView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:1.0 animations:^{
        self.mapView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            [self.radiusView setAlpha:1.0];
            [self.crossImageView setAlpha:1.0];
            [self.myLocButton setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self setLocationRadius:self.radius];
        }];
        if (self.area.latitude.length > 0 && self.area.longitude.length > 0) {
            [self showCoordinate:CLLocationCoordinate2DMake([self.area.latitude doubleValue], [self.area.longitude doubleValue])];
            [self setUpdateUserLocation:NO];
            [self.mapView setShowsUserLocation:YES];
            [self.textField setText:self.area.name];
        } else {
            [self.mapView setShowsUserLocation:YES];
        }
        if (DEBUG_MODE) {
            [self addAreaCircles];
        }
        [self showSetButton];
    }];
}

- (void)addAreaCircles
{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for (Area *area in [[AppManager sharedInstance] areaArray]) {
        double latitude = [area.latitude doubleValue];
        double longitude = [area.longitude doubleValue];
        double radius = [area.radius doubleValue];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius:radius];
        [self.mapView addOverlay:circle];
    }
}

- (void)myLocButtonDidClicked:(UIButton *)button
{
    [self showCoordinate:self.mapView.userLocation.location.coordinate];
}

- (void)cancelButtonDidClicked:(UIButton *)button
{
    [self showSetButton];
}

- (void)confirmButtonDidClicked:(UIButton *)button
{
    if (self.placeName.length > 0) {
        // Database area
        NSMutableArray *areaArray = [[AppManager sharedInstance] areaArray];
        
        if (![areaArray containsObject:self.area]) {
            [areaArray addObject:self.area];
        }
        [self.area setLatitude:[NSString stringWithFormat:@"%f", self.targetLocation.latitude]];
        [self.area setLongitude:[NSString stringWithFormat:@"%f", self.targetLocation.longitude]];
        [self.area setRadius:[NSString stringWithFormat:@"%f", self.radius]];
        [self.area setName:self.placeName];
        [self.area save];
        
        // Delete
        [GFUtils deleteGeoFenceConfig:areaArray];
        // Set flag
        for (Area *area in areaArray) {
            [area setSend_flag:@"0"];
            [area.notificationIn setSend_flag:@"0"];
            [area.notificationOut setSend_flag:@"0"];
        }
        
        if (self.settingType != SettingTypeInit) {
            // Config
            if ([GFUtils configGeoFence:areaArray]) {
                DLog(@"Config geo fence success");
            }
        }
        
        [[AppManager sharedInstance] setLocationEdited:YES];
        [[AppManager sharedInstance] setSettingNeedReload:YES];
        
        if (self.settingType == SettingTypeEdit || self.settingType == SettingTypeReEdit || self.settingType == SettingTypeAdd) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            LegalViewController *legalViewController = [[LegalViewController alloc] init];
            [self.navigationController pushViewController:legalViewController animated:YES];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"ごめんなさい！その場所は設定できないんです。別な地名でレッツリトライ！もしかしたら、iPhoneの位置情報サービスで\"俺残\"が無効になっているかも。確認してね。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)clearButtonDidClicked:(UIButton *)button
{
    [self.textField setText:@""];
    [self.textField resignFirstResponder];
}

#pragma mark - MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [manager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
    }
    self.authorizationStatus = status;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self setLocationRadius:self.radius];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location = [userLocation coordinate];
    
    if ([self updateUserLocation]) {
        [self setUpdateUserLocation:NO];
        [self showCoordinate:location];
    }
//    DLog(@"User Location: %f, %f", location.latitude, location.longitude);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *PinIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        [annotationView setImage:[UIImage imageNamed:@"current_location"]];
    }
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = nil;
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = overlay;
        circleView = [[MKCircleView alloc] initWithCircle:circle];
        [circleView setStrokeColor:[UIColor colorWithRed:0.41 green:0.65 blue:0.95 alpha:1]];
        [circleView setFillColor:[UIColor colorWithRed:0.83 green:0.93 blue:1 alpha:0.8]];
        [circleView setLineWidth:1.0];
    }
    [self setLocationRadius:self.radius];
    return circleView;
}

- (void)showCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1500.0, 1500.0);
    [self.mapView setRegion:region animated:YES];
}

- (void)putPin
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(31, 104);
    MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:location title:@"haha"];
    [self.mapView addAnnotation:mapPoint];
    
    [self showCoordinate:location];
}

- (void)performSearch:(NSString *)keyWord
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = keyWord;
    request.region = self.mapView.region;
    
    NSMutableArray *matchingItems = [[NSMutableArray alloc] init];
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error || response.mapItems.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"ごめんなさい！検索した地名はなかったです...。\n別な地名でレッツリトライ！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        } else {
            for (MKMapItem *item in response.mapItems)
            {
                [matchingItems addObject:item];

                [self showCoordinate:item.placemark.coordinate];
                
                [self stringForPlacemark:item.placemark];
                
                break;
            }
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (NSString *)stringForPlacemark:(MKPlacemark *)placemark
{
    DLog(@"%@", placemark.addressDictionary);
    
//    for (id string in placemark.addressDictionary) {
//        id value = [placemark.addressDictionary objectForKey:string];
//        if ([value isKindOfClass:[NSString class]]) {
//            DLog(@"%@ : %@", string, value);
//        } else {
//            for (id sub in value) {
//                DLog(@"%@ : %@", string, sub);
//            }
//        }
//    }
    NSString *place = @"";
//    if (placemark.thoroughfare.length > 0 && placemark.name.length > 0) {
//        if ([placemark.name hasPrefix:placemark.thoroughfare]) {
//            place = placemark.name;
//        } else {
//            place = [NSString stringWithFormat:@"%@ %@", placemark.thoroughfare, placemark.name];
//        }
//    } else if (placemark.thoroughfare.length > 0 && placemark.name.length == 0) {
//        place = placemark.thoroughfare;
//    } else if (placemark.thoroughfare.length == 0 && placemark.name.length > 0) {
//        place = placemark.name;
//    }

    NSString *state = [placemark.addressDictionary objectForKey:@"State"];
    NSString *city = [placemark.addressDictionary objectForKey:@"City"];
    
    if (state.length > 0 && city.length > 0) {
        place = [NSString stringWithFormat:@"%@ %@", state, city];
    } else if (state.length > 0 && city.length == 0) {
        place = state;
    } else if (state.length == 0 && city.length > 0) {
        place = city;
    }
    DLog(@"Place:%@", place);
    
    if (self.textField.text.length == 0 || !self.userInputText) {
        [self setUserInputText:NO];
        self.textField.text = place;
    }
    
    
    return place;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setUserInputText:YES];
    
    if (textField.text.length > 0) {
        [self performSearch:textField.text];
    }
}

@end

//
//  LocationManager.m
//  TramChallenge
//
//  Created by Stephen Sykes on 30/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "LocationManager.h"
#import "MapViewController.h"

@interface LocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MapViewController *mapViewController;

@end

@implementation LocationManager

static LocationManager *_LocationManager;

+ (LocationManager *)instance
{
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _LocationManager = [[self alloc] init];
    });
    return _LocationManager;
}

- (void)registerMapViewController:(MapViewController *)mapViewController
{
    self.mapViewController = mapViewController;
}

- (void)start
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    [self updateForAuthorizationStatus:[CLLocationManager authorizationStatus]];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)attemptPermission
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enable location services"
                                                                       message:@"Your attempt can't be properly registered if you do not enable location services. Please open this app's settings and set location access to 'While Using the App'"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication openURL:url];
        }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];

        [alert addAction:noAction];
        [alert addAction:settingsAction];

        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{}];
    }

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self updateForAuthorizationStatus:status];
}

- (void)updateForAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapViewController.showsUserLocation = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    self.userLocation = location;
}

@end

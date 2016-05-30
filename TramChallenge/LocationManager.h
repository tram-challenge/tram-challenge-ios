//
//  LocationManager.h
//  TramChallenge
//
//  Created by Stephen Sykes on 30/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@class MapViewController;


@interface LocationManager : NSObject

+ (LocationManager *)instance;

@property (nonatomic) CLLocation *userLocation;

- (void)registerMapViewController:(MapViewController *)mapViewController;
- (void)start;
- (void)attemptPermission;

@end

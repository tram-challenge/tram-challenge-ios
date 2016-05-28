//
//  TCTramStop.h
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TCTramStop : NSObject

@property (nonatomic) NSString *id;
@property (nonatomic) CLLocationCoordinate2D coord;
@property (nonatomic) NSString *name;
@property (nonatomic) NSArray<NSString *> *routes;
@property (nonatomic) NSArray<NSDictionary<NSString *, NSString *> *> *links;
@property (nonatomic) NSArray<NSString *> *hsl_ids;
@property (nonatomic) NSArray<NSString *> *stop_numbers;

@end

//
//  RouteData.h
//  TramChallenge
//
//  Created by Stephen Sykes on 24/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RouteData : NSObject

//- (void)fetchRoutes

+ (NSArray *)coordsForRoute:(NSString *)routeName;
+ (NSArray *)routeNames;
+ (UIColor *)colorForRouteName:(NSString *)routeName;

@end

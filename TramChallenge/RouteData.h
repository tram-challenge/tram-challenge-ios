//
//  RouteData.h
//  TramChallenge
//
//  Created by Stephen Sykes on 24/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TCTramStop, TCTramRoute;

@interface RouteData : NSObject

+ (RouteData *)instance;

- (NSArray *)coordsForRoute:(NSString *)routeName;
+ (NSArray *)routeNames;
+ (UIColor *)colorForRouteName:(NSString *)routeName;

- (void)fetchStopsSuccess:(void (^)())successBlock;
- (NSArray<TCTramStop *> *)stopsForRoute:(NSString *)routeName;

- (TCTramRoute *)routeForRouteName:(NSString *)name;
- (NSSet<TCTramStop *> *)stops;
- (NSSet<TCTramStop *> *)visitedStops;
- (NSSet<TCTramStop *> *)unvisitedStops;

/**
 Does not send to backend, just marks locally
 */
- (void)markStopAsVisited:(NSString *)stopID;
- (void)clearVisitedStops;

@end

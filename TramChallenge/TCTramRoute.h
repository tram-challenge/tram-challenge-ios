//
//  TCTramRoute.h
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TCTramStop;

@interface TCTramRoute : NSObject

@property (nonatomic) NSString *routeName;
@property (nonatomic) NSMutableArray *stops;

- (UIColor *)colorForStop:(TCTramStop *)stop;

@end

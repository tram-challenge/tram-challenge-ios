//
//  TCTramRoute.m
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCTramRoute.h"

@implementation TCTramRoute

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stops = [NSMutableArray array];
    }
    return self;
}

@end

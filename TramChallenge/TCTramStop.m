//
//  TCTramStop.m
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCTramStop.h"
#import "TCAPIAdaptor.h"

@interface TCTramStop ()

@end

@implementation TCTramStop

- (void)markVisited
{
    _visited = YES;
    [[TCAPIAdaptor instance] markVisited:self.id success:^{
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
    }];
}

- (void)markUnvisited
{
    _visited = NO;
    [[TCAPIAdaptor instance] markUnvisited:self.id success:^{
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
    }];
}

@end

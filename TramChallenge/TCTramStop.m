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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self markVisited];
        });
    }];
}

- (void)markUnvisited
{
    _visited = NO;
    [[TCAPIAdaptor instance] markUnvisited:self.id success:^{
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self markUnvisited];
        });
    }];
}

@end

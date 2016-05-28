//
//  TCAPIAdaptor.h
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TCErrorBlock)(NSError *error, NSInteger status, NSDictionary *info);

@interface TCAPIAdaptor : NSObject

+ (TCAPIAdaptor *)instance;

- (void)getRoutesWithSuccess:(void (^)(NSArray *routes))successBlock
                     failure:(TCErrorBlock)failureBlock;
@end

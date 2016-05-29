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

@property (nonatomic) NSString *attemptID;
@property (nonatomic) NSString *startedAt;
@property (nonatomic) NSNumber *elapsedTime;
@property (nonatomic) NSString *currentTime;

+ (TCAPIAdaptor *)instance;

- (void)getRoutesWithSuccess:(void (^)(NSArray *routes))successBlock
                     failure:(TCErrorBlock)failureBlock;

- (void)startAttemptForNickname:(NSString *)nickname
                        success:(void (^)())successBlock
                        failure:(void (^)())failureBlock;
- (void)abortAttempt:(void (^)())successBlock
             failure:(void (^)())failureBlock;

- (void)markVisited:(NSString *)stopID success:(void (^)())successBlock
            failure:(TCErrorBlock)failureBlock;
- (void)markUnvisited:(NSString *)stopID success:(void (^)())successBlock
              failure:(TCErrorBlock)failureBlock;

- (BOOL)attemptInProgress;

/**
 Result dict keys are unique vehicle id
 Values are arrays containing lat, long and line id (eg "1007A")
 */
- (void)tramPositions:(void (^)(NSDictionary *))successBlock;

@end

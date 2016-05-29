//
//  TCAPIAdaptor.m
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCAPIAdaptor.h"
#import "TCUtilities.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "RouteData.h"

static NSString * const apiURL = @"https://tramchallenge.com";
static NSString *const digitransportURL = @"https://api.digitransit.fi";

@interface TCAPIAdaptor ()

@property (nonatomic) NSInteger spinnerCount;

@end

@implementation TCAPIAdaptor

static TCAPIAdaptor *_TCAPIAdaptor;

+ (TCAPIAdaptor *)instance
{
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _TCAPIAdaptor = [[self alloc] init];
    });
    return _TCAPIAdaptor;
}

- (NSString *)cloudID
{
    NSString *id = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).cloudID;
    return id ?: @"Test";
}

- (BOOL)attemptInProgress {
    return self.attemptID != nil;
}

- (void)getRoutesWithSuccess:(void (^)(NSArray *routes))successBlock
                            failure:(TCErrorBlock)failureBlock
{
    NSString *path = @"api/stops";

    [self get:path with:nil success:^(AFHTTPRequestOperation *operation, id result) {
        NSArray *routes = [NSArray tc_cast:result];
        successBlock(routes);
    } failure:failureBlock];
}

- (void)startAttemptForNickname:(NSString *)nickname
                        success:(void (^)())successBlock
                        failure:(void (^)())failureBlock
{
    NSString *path = @"api/attempts";
    NSDictionary *params = @{@"icloud_user_id" : [self cloudID], @"nickname" : nickname};
    [self post:path with:params success:^(AFHTTPRequestOperation *operation, id result) {
        NSDictionary *dict = [NSDictionary tc_cast:result];
        self.attemptID = dict[@"id"];
        self.startedAt = dict[@"started_at"];
        self.elapsedTime = [NSNumber tc_cast:dict[@"elapsed_time"]];
        self.currentTime = dict[@"current_time"];

        for (NSDictionary *stopDict in dict[@"stops"]) {
            NSString *stopID = stopDict[@"id"];
            if (stopDict[@"visited_at"] != [NSNull null]) {
                [[RouteData instance] markStopAsVisited:stopID];
            }
        }

        successBlock();
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}

- (void)abortAttempt:(void (^)())successBlock
             failure:(void (^)())failureBlock
{
    NSString *path = [NSString stringWithFormat:@"api/attempts/%@", self.attemptID];
    NSDictionary *params = @{@"icloud_user_id" : [self cloudID]};
    [self put:path with:params success:^(AFHTTPRequestOperation *operation, id result) {
        successBlock();
        self.attemptID = nil;
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        if (failureBlock) failureBlock();
    }];
}

- (void)markVisited:(NSString *)stopID success:(void (^)())successBlock
            failure:(TCErrorBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"api/stops/%@", stopID];
    NSDictionary *params = @{@"stop" : @{@"visited" : @YES},
                             @"icloud_user_id" : [self cloudID]};
    [self put:path with:params success:^(AFHTTPRequestOperation *operation, id result) {
        lg(@"stop visited ok");
        successBlock();
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        lg(@"error %@", error);
        if (failureBlock) failureBlock(error, status, info);
    }];
}

- (void)markUnvisited:(NSString *)stopID success:(void (^)())successBlock
            failure:(TCErrorBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"api/stops/%@", stopID];
    NSDictionary *params = @{@"stop" : @{@"visited" : @NO},
                             @"icloud_user_id" : [self cloudID]};
    [self put:path with:params success:^(AFHTTPRequestOperation *operation, id result) {
        lg(@"stop unvisited ok");
        successBlock();
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        lg(@"error %@", error);
        if (failureBlock) failureBlock(error, status, info);
    }];
}

- (void)tramPositions:(void (^)(NSDictionary *))successBlock
{
    NSString *path = @"realtime/vehicle-positions/v1/hfp/journey/tram/#";
    [self getDigitransport:path with:nil success:^(AFHTTPRequestOperation *operation, id result) {
        NSDictionary *dict = [NSDictionary tc_cast:result];
        NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
        for (NSString *key in dict) {
            NSDictionary *itemDict = [NSDictionary tc_cast:dict[key]];
            NSDictionary *item = [NSDictionary tc_cast:itemDict[@"VP"]];
            resDict[item[@"veh"]] = @[item[@"lat"], item[@"long"], item[@"line"]];
        }
        successBlock(resDict);
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {

    }];
}


#pragma mark - HTTP interface

- (void)get:(NSString *)resource
       with:(NSDictionary *)params
    success:(void (^)(AFHTTPRequestOperation *operation, id result))successBlock
    failure:(TCErrorBlock)failureBlock
{
    lg(@"GET API call: %@ params: %@", resource, params);

    NSURL *baseURL = [NSURL URLWithString:apiURL];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    [self spinnerOn];
    AFHTTPRequestOperation *op = [manager GET:resource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self spinnerOff];
#ifdef MOR_GET_RESPONSE_DEBUGGING
        lg(@"GET response: %@", responseObject);
#endif
        if (successBlock) successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self spinnerOff];
        [self handleFailureWithBlock:failureBlock forError:error inOperation:operation];
    }];
    lg(@"URL: %@", op.request.URL);
}

- (void)getDigitransport:(NSString *)resource
       with:(NSDictionary *)params
    success:(void (^)(AFHTTPRequestOperation *operation, id result))successBlock
    failure:(TCErrorBlock)failureBlock
{
    lg(@"GET API call: %@ params: %@", resource, params);

    NSURL *baseURL = [NSURL URLWithString:digitransportURL];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    [self spinnerOn];
    AFHTTPRequestOperation *op = [manager GET:resource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self spinnerOff];
#ifdef MOR_GET_RESPONSE_DEBUGGING
        lg(@"GET response: %@", responseObject);
#endif
        if (successBlock) successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self spinnerOff];
        [self handleFailureWithBlock:failureBlock forError:error inOperation:operation];
    }];
    lg(@"URL: %@", op.request.URL);
}

- (void)post:(NSString *)resource
        with:(NSDictionary *)params
     success:(void (^)(AFHTTPRequestOperation *operation, id result))successBlock
     failure:(TCErrorBlock)failureBlock
{
    lg(@"POST API call: %@ params: %@", resource, params);

    NSURL *baseURL = [NSURL URLWithString:apiURL];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    // Server can respond with empty response, or plain text, so allow that
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer], [AFHTTPResponseSerializer serializer]]];
    manager.responseSerializer = serializer;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];

    [self spinnerOn];
    [manager POST:resource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self spinnerOff];
        lg(@"POST response: %@", responseObject);
        if (successBlock) successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self spinnerOff];
        [self handleFailureWithBlock:failureBlock forError:error inOperation:operation];
    }];
}

- (void)put:(NSString *)resource
       with:(NSDictionary *)params
    success:(void (^)(AFHTTPRequestOperation *operation, id result))successBlock
    failure:(TCErrorBlock)failureBlock
{
    lg(@"PUT API call: %@ params: %@", resource, params);

    NSURL *baseURL = [NSURL URLWithString:apiURL];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [self spinnerOn];
    [manager PUT:resource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self spinnerOff];
        lg(@"PUT response: %@", responseObject);
        if (successBlock) successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self spinnerOff];
        [self handleFailureWithBlock:failureBlock forError:error inOperation:operation];
    }];
}

- (void)handleFailureWithBlock:(TCErrorBlock)failureBlock
                      forError:(NSError *)error
                   inOperation:(AFHTTPRequestOperation *)operation
{
    NSLog(@"Error requesting %@: %@ (%@)", operation.request.URL.absoluteString, error, operation.responseString);

    NSDictionary *info = [NSDictionary tc_cast:operation.responseObject];
    if (failureBlock) failureBlock(error, operation.response.statusCode, info);
}

#pragma mark - Spinner

- (void)spinnerOn
{
    @synchronized(self) {
        self.spinnerCount++;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        // Never allow the spinner to be active for more than 30s, prevents stuck spinners
        [TCUtilities executeMostRecentAfter:30 identifier:@"spinner" block:^{
            [self spinnerOff];
        }];
    }
}

- (void)spinnerOff
{
    @synchronized(self) {
        self.spinnerCount--;
        if (_spinnerCount <= 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.spinnerCount = 0;
        }
    }
}


@end

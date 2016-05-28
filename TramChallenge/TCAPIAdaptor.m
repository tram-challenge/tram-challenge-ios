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

static NSString * const apiURL = @"https://dev.tramchallenge.com";

@interface TCAPIAdaptor ()

@property (nonatomic) NSInteger spinnerCount;

@end

@implementation TCAPIAdaptor

- (void)getRoutesWithSuccess:(void (^)(NSArray *routes))successBlock
                            failure:(TCErrorBlock)failureBlock
{
    NSString *path = @"api/routes";

    [self get:path with:nil success:^(AFHTTPRequestOperation *operation, id result) {
        NSArray *routes = [NSArray tc_cast:result];
        successBlock(routes);
    } failure:failureBlock];
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

//
//  AppDelegate.m
//  TramChallenge
//
//  Created by Stephen Sykes on 19/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "AppDelegate.h"
#import "TCUtilities.h"
#import "TCTabBarController.h"
#import "AttemptViewController.h"
#import "ChallengeNavigationController.h"
@import CloudKit;
#import <HockeySDK/HockeySDK.h>

#if DEBUG
#import <SimulatorStatusMagic/SDStatusBarManager.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window setTintColor:[UIColor colorWithRed:0 green:0.6 blue:0.36 alpha:1]];
    // Override point for customization after application launch.

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"35b5ce51ddb941e69449c7decb6d7536"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    [self fetchCloudID];

    #if DEBUG
    [[SDStatusBarManager sharedInstance] enableOverrides];
    #endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)fetchCloudID
{
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        lg(@"CLOUDKIT Fetching User Record ID");

        if (error) {
            lg(@"[%@] Error loading CloudKit user: %@", self.class, error);

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            NSString *uuid = [defaults stringForKey:@"uuid"];
            if (uuid == nil) {
                uuid = [[NSUUID UUID] UUIDString];
                [defaults setObject:uuid forKey:@"uuid"];
                [defaults synchronize];
            }
            self.cloudID = uuid;
        }

        if (recordID) {
            lg(@"CLOUDKIT Found User Record ID: %@ xxxxx %@", recordID, recordID.recordName);
            self.cloudID = recordID.recordName;
        }
    }];
}

- (void)completed
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Challenge completed"
                                                                   message:@"Looks like you visited all the stops!"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* finishAction = [UIAlertAction actionWithTitle:@"Finish" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        TCTabBarController *controller = (TCTabBarController *)self.window.rootViewController;
        controller.selectedIndex = 0;
        ChallengeNavigationController *challengeNavController = (ChallengeNavigationController *)controller.selectedViewController;

        [(AttemptViewController *)challengeNavController.visibleViewController challengeCompleted];
    }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Not completed yet" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];

    [alert addAction:finishAction];
    [alert addAction:noAction];

    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{}];

}

@end

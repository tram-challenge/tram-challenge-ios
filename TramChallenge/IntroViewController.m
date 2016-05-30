//
//  SecondViewController.m
//  TramChallenge
//
//  Created by Stephen Sykes on 19/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "IntroViewController.h"
#import "TCAPIAdaptor.h"
#import "RouteData.h"
@import SafariServices;
#import "TCTramStop.h"
#import "LocationManager.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startChallengeButton.layer.cornerRadius = 8;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *nickname = [defaults stringForKey:@"nickname"];
    self.nicknameField.text = nickname;
    [self setButtonStatus:self.nicknameField.text.length > 0];

    [self.nicknameField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    [[RouteData instance] fetchStopsSuccess:^{}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"in_progress"]) {
        [self.startChallengeButton setTitle:@"Resume Challenge" forState:UIControlStateNormal];
    } else {
        [self.startChallengeButton setTitle:@"Start Challenge" forState:UIControlStateNormal];
    }
}

- (IBAction)startChallenge:(id)sender {
    [self setButtonStatus:NO];
    [self.nicknameField resignFirstResponder];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nicknameField.text forKey:@"nickname"];
    [defaults setBool:YES forKey:@"in_progress"];
    [defaults synchronize];

    [[LocationManager instance] start];
    [[LocationManager instance] attemptPermission];

    [[TCAPIAdaptor instance] startAttemptForNickname:self.nicknameField.text success:^() {
        // NEARLY complete challenge TEMP
//        NSSet<TCTramStop *> *stops = [[RouteData instance] stops];
//        BOOL skip = YES;
//        for (TCTramStop *stop in stops) {
//            if (!skip) [stop markVisited];
//            skip = NO;
//        }
        // TEMP

        [self performSegueWithIdentifier:@"StartChallengeSegue" sender:sender];
        [self setButtonStatus:YES];
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        [self setButtonStatus:YES];
    }];
}
- (IBAction)viewRules:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://tramchallenge.com/rules"];
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(id)event {
    [self setButtonStatus:self.nicknameField.text.length > 0];
}

- (void)setButtonStatus:(BOOL)enabled {
    self.startChallengeButton.enabled = enabled;
    self.startChallengeButton.layer.opacity = enabled ? 1 : 0.5;
}

@end

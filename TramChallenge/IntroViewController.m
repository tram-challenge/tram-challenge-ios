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

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startChallengeButton.layer.cornerRadius = 8;

    [self setButtonStatus:NO];

    [self.nicknameField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    [[RouteData instance] fetchStopsSuccess:^{}];
}

- (IBAction)startChallenge:(id)sender {
    [self setButtonStatus:NO];
    [self.nicknameField resignFirstResponder];

    [[TCAPIAdaptor instance] startAttemptForNickname:self.nicknameField.text success:^() {
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

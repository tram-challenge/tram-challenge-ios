//
//  SecondViewController.h
//  TramChallenge
//
//  Created by Stephen Sykes on 19/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startChallengeButton;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;

@end


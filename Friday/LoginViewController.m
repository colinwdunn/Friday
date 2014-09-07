//
//  LoginViewController.m
//  Friday
//
//  Created by Joseph Anderson on 6/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "LoginViewController.h"
#import "SplashViewController.h"
#import "CameraViewController.h"
#import <Parse/Parse.h>
#import "Roll.h"
#import "UserRoll.h"
#import "RollChoiceViewController.h"
#import <Crashlytics/Crashlytics.h>


//nico: 281-249-9718
@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;


- (void)signInWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber;
- (void)signUpWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber;

- (IBAction)onLoginButton:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.nameField becomeFirstResponder];
}

- (IBAction)onLoginButton:(id)sender {
    NSString *username = self.nameField.text;
    NSString *phoneNumber = self.phoneNumberField.text;
    
    PFQuery *query = [User query];
    [query whereKey:@"phoneNumber" equalTo:phoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            [self signInWithUsername:username andPhoneNumber:phoneNumber];
        } else {
            [self signUpWithUsername:username andPhoneNumber:phoneNumber];
        }
    }];
}

- (void)signInWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber {
    [User logInWithUsernameInBackground:username password:@"asdf" block:^(PFUser *user, NSError *error) {
        PFQuery *userRollQuery = [UserRoll query];
        [userRollQuery whereKey:@"phoneNumber" equalTo:phoneNumber];
        [userRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                NSLog(@"User was invited to a roll before.. redirecting to choose from list");
                RollChoiceViewController *rollChoiceVC = [[RollChoiceViewController alloc] init];
                [self presentViewController:rollChoiceVC animated:YES completion:nil];
            } else {
                //user not invited but has a currentRoll
                [Roll setCurrentRollFromParseWithBlock:^(NSError *error) {
                    NSLog(@"Getting Current Roll from Parse for currentUser");
                    CameraViewController *cameraVC = [[CameraViewController alloc] init];
                    [self presentViewController:cameraVC animated:YES completion:nil];
                }];
            }
        }];
    }];
}

- (void)signUpWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber {
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = @"asdf";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [User currentUser].phoneNumber = phoneNumber;
            [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFQuery *userRollQuery = [UserRoll query];
                [userRollQuery whereKey:@"phoneNumber" equalTo:phoneNumber];
                [userRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        if (objects.count > 0) {
                            RollChoiceViewController *rollChoiceVC = [[RollChoiceViewController alloc] init];
                            [self presentViewController:rollChoiceVC animated:YES completion:nil];
                        } else {
                            [Roll createRollWithBlock:^(NSError *error) {
                                SplashViewController *splashVC = [[SplashViewController alloc] init];
                                [self presentViewController:splashVC animated:YES completion:nil];
                            }];
                        }
                    }
                }];
            }];

        }
    }];
}
- (IBAction)crashTestButtonWasTapped:(id)sender {
    [[Crashlytics sharedInstance] crash];
}

@end


// for invited user/push notifications
//[[[Roll alloc] init] getInvitedToRoll];

//            [[[Roll alloc] init] getCurrentRoll:[User currentUser] withSuccess:^(Roll *currentRoll) {
//                [User currentUser].currentRoll = currentRoll;
//                SplashViewController *splashVC = [[SplashViewController alloc] init];
//                splashVC.roll = currentRoll;
//                [self presentViewController:splashVC animated:YES completion:nil];
//            } andFailure:^(NSError *error) {
//                //FAILED
//            }];

//            PFQuery *query = [PFQuery queryWithClassName:@"UserRolls"];
//            [query whereKey:@"invitedUsername" equalTo:username];
//            [query includeKey:@"roll"];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                PFObject *userRoll = [objects firstObject];
//                PFObject *currentRoll = [userRoll objectForKey:@"roll"];
//                userRoll[@"user"] = [PFUser currentUser];
//
//                [User currentUser].currentRoll = (Roll *)currentRoll;
//                [[User currentUser] saveInBackground];
//
//                //push notifications:
//                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@"has joined.", @"message", username, @"name",  nil];
//
//                PFPush *push = [[PFPush alloc] init];
//                [push setChannel:currentRoll.objectId];
//                [push setData:data];
//                [push sendPushInBackground];
//
//                [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    SplashViewController *splashVC = [[SplashViewController alloc] init];
//                    splashVC.roll = currentRoll;
//                    [self presentViewController:splashVC animated:YES completion:nil];
//                }];
//            }];

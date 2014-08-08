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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)onLoginButton:(id)sender;

//- (void)presentCameraViewController;

- (void)signUpWithUsername:(NSString *)username;
- (void)signInWithUsername:(NSString *)username;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameField becomeFirstResponder];
}

- (IBAction)onLoginButton:(id)sender {
    NSString *name = self.nameField.text;
    PFQuery *query = [User query];
    [query whereKey:@"username" equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            [self signInWithUsername:name];
        } else {
            [self signUpWithUsername:name];
        }
    }];
}

- (void)signInWithUsername:(NSString *)username {
    [User logInWithUsernameInBackground:username password:@"asdf" block:^(PFUser *user, NSError *error) {
        PFQuery *UserRollQuery = [UserRoll query];
        [UserRollQuery whereKey:@"invitedUserName" equalTo:username];
        [UserRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                RollChoiceViewController *rollChoiceVC = [[RollChoiceViewController alloc] init];
                [self presentViewController:rollChoiceVC animated:YES completion:nil];
            } else {
                [Roll createRollWithBlock:^(NSError *error) {
                    NSLog(@"Roll was created.");
                    CameraViewController *cameraVC = [[CameraViewController alloc] init];
                    [self presentViewController:cameraVC animated:YES completion:nil];
                }];
            }
        }];
     
    }];
}

- (void)signUpWithUsername:(NSString *)username {
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = @"asdf";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFQuery *UserRollQuery = [UserRoll query];
            [UserRollQuery whereKey:@"invitedUserName" equalTo:username];
            [UserRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count > 0) {
                    RollChoiceViewController *rollChoiceVC = [[RollChoiceViewController alloc] init];
                    [self presentViewController:rollChoiceVC animated:YES completion:nil];
                    } else {
                        [Roll createRollWithBlock:^(NSError *error) {
                            NSLog(@"Roll was created.");
                            SplashViewController *splashVC = [[SplashViewController alloc] init];
                            [self presentViewController:splashVC animated:YES completion:nil];
                        }];
                    }
                }];
        }
    }];
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

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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)onLoginButton:(id)sender;
- (IBAction)loginDidPress:(id)sender;

- (void)presentCameraViewController;

@end

@implementation LoginViewController

- (IBAction)onLoginButton:(id)sender {
//    NSString *name = self.nameField.text;
//    PFQuery *query = [User query];
//    [query whereKey:@"username" equalTo:name];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (objects.count > 0) {
//            User *user = objects[0];
//            NSLog(@"user: %@", user);
//        
//            [User logInWithUsernameInBackground:name password:@"asdf" block:^(PFUser *user, NSError *error) {
//                NSLog(@"I've cracked the user credentials!");
//                [self presentCameraViewController];
//            }];
//        }
//    }];
    
    //login with phone number flow
    NSString *username = self.nameField.text;
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = @"asdf";
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFQuery *query = [PFQuery queryWithClassName:@"UserRolls"];
            [query whereKey:@"invitedUsername" equalTo:username];
            [query includeKey:@"roll"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *userRoll = [objects firstObject];
                PFObject *currentRoll = [userRoll objectForKey:@"roll"];
                userRoll[@"user"] = [PFUser currentUser];
                
                [User currentUser].currentRoll = (Roll *)currentRoll;
                [[User currentUser] saveInBackground];
                
                //push notifications:
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@"has joined.", @"message", username, @"name",  nil];
                
                PFPush *push = [[PFPush alloc] init];
                [push setChannel:currentRoll.objectId];
                [push setData:data];    
                [push sendPushInBackground];
                
                [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    SplashViewController *splashVC = [[SplashViewController alloc] init];
                    splashVC.roll = currentRoll;
                    [self presentViewController:splashVC animated:YES completion:nil];
                }];
            }];
        }
    }];
    
    
}

- (IBAction)loginDidPress:(id)sender {
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    [PFFacebookUtils initializeFacebook];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            //weee
            if (!error) {
                NSLog(@"User canceled the facebook login");
            } else {
                NSLog(@"An error occured* %@", error);
                }
        
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in");
            FBRequest *request = [FBRequest requestForMe];
            
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSDictionary *userData = (NSDictionary *)result;
                PFUser *user = [PFUser currentUser];
                user.username = userData[@"name"];
                user.email = userData[@"email"];
                
                
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [[[Roll alloc] init] getCurrentRoll:[User currentUser] withSuccess:^(Roll *currentRoll) {
                            SplashViewController *splashVC = [[SplashViewController alloc] init];
                            splashVC.roll = currentRoll;
                            [self presentViewController:splashVC animated:YES completion:nil];
                        } andFailure:^(NSError *error) {
                        //FAILED
                        }];
                    }];
            }];

            } else {
                [[User currentUser].currentRoll fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSLog(@"User with facebook logged in");
                    [self presentCameraViewController];
                }];
            }
    }];
    
}

- (void)presentCameraViewController {
    PFQuery *query = [PFQuery queryWithClassName:@"UserRolls"];
    [query whereKey:@"user" equalTo:[User currentUser]];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query includeKey:@"roll"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *userRoll = objects[0];
        PFObject *currentRoll = [userRoll objectForKey:@"roll"];
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        // TODO: Update roll status to accepted
        cameraVC.roll = currentRoll;
        [self presentViewController:cameraVC animated:YES completion:nil];
    }];
}

@end

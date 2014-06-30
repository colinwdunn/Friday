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
- (IBAction)loginDidPress:(id)sender;

@end

@implementation LoginViewController

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
                    PFObject *firstRoll = [PFObject objectWithClassName:@"Roll"];
                    firstRoll[@"userId"] = [[PFUser currentUser] objectId];
                    [firstRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        PFObject *userRoll = [PFObject objectWithClassName:@"UserRolls"];
                        userRoll[@"userId"] = [[PFUser currentUser] objectId];
                        userRoll[@"rollId"] = firstRoll.objectId;
                        userRoll[@"status"] = @"accepted";
                        [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            SplashViewController *splashVC = [[SplashViewController alloc] init];
                            Roll *roll = [[Roll alloc] init];
                            roll.rollId = firstRoll.objectId;
                            splashVC.roll = roll;
                            [self presentViewController:splashVC animated:YES completion:nil];
                        }];
                    }];
                }];
                
            }];

        } else {
            NSLog(@"User with facebook logged in");
            PFQuery *query = [PFQuery queryWithClassName:@"Roll"];
            [query whereKey:@"userId" equalTo:[[PFUser currentUser] objectId]];
            [query orderByDescending:@"createdAt"];
            query.limit = 1;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                CameraViewController *cameraVC = [[CameraViewController alloc] init];
                Roll *roll = [[Roll alloc] init];
                PFObject *currentRoll = objects[0];
                roll.rollId = currentRoll.objectId;
                cameraVC.roll = roll;
                
                [self presentViewController:cameraVC animated:YES completion:nil];
            }];
            // Present splash view controller if user hasnt taken photo
            // else present camera view controller
        }
        
        
        
    }];
    
}

@end

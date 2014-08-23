//
//  RollChoiceViewController.m
//  Friday
//
//  Created by Yousra Kamoona on 8/6/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "RollChoiceViewController.h"
#import "SplashViewController.h"
#import "CameraViewController.h"
#import "UserRoll.h"

@interface RollChoiceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *useInvitedToRollButton;
@property (weak, nonatomic) IBOutlet UIButton *startNewRollButton;
@property (weak, nonatomic) IBOutlet UIButton *continuExistingRollButton;

- (IBAction)useInvitedToButtonTapped:(id)sender;
- (IBAction)startNewRollButtonTapped:(id)sender;
- (IBAction)continuExistingRollButtonTapped:(id)sender;

@end

@implementation RollChoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)useInvitedToButtonTapped:(id)sender {
    //update roll status to accepted. 
    [Roll setCurrentRollFromUserRollWithBlock:^(NSError *error) {
        if ([User currentUser].isNew) {
            SplashViewController *splashVC = [[SplashViewController alloc] init];
            [self presentViewController:splashVC animated:YES completion:nil];
        } else {
            CameraViewController *cameraVC = [[CameraViewController alloc] init];
            [self presentViewController:cameraVC animated:YES completion:nil];
        }
        
    }];
}

- (IBAction)startNewRollButtonTapped:(id)sender {
    [Roll createRollWithBlock:^(NSError *error) {
        if ([User currentUser].isNew) {
            SplashViewController *splashVC = [[SplashViewController alloc] init];
            [self presentViewController:splashVC animated:YES completion:nil];
        } else {
            CameraViewController *cameraVC = [[CameraViewController alloc] init];
            [self presentViewController:cameraVC animated:YES completion:nil];
        }
    }];
}

- (IBAction)continuExistingRollButtonTapped:(id)sender {
    [Roll currentRoll];
    if ([User currentUser].isNew) {
        SplashViewController *splashVC = [[SplashViewController alloc] init];
        [self presentViewController:splashVC animated:YES completion:nil];
    } else {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        [self presentViewController:cameraVC animated:YES completion:nil];
    }
}
@end

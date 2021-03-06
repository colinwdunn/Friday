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
#import "FridayCamera.h"
#import <GPUImage/GPUImage.h>


@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (weak, nonatomic) IBOutlet UIView *blurCamera;
@property (strong, nonatomic) GPUImageVideoCamera *gpuImageVideoCamera;

- (void)signInWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber;
- (void)signUpWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber;

- (IBAction)onLoginButton:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FridayCamera sharedCameraInstance] initCameraSessionWithView:self];
    [self setupGPUImageBlurView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.nameField) {
       [self.nameField becomeFirstResponder];
    } else if (textField == self.phoneNumberField) {
        [self.phoneNumberField becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.nameField) {
        [self.nameField resignFirstResponder];
    } else if (textField == self.phoneNumberField) {
         [self.phoneNumberField resignFirstResponder];
    }
   
    return YES;
}

- (void)signInWithUsername:(NSString *)username andPhoneNumber:(NSString *)phoneNumber {
    [User logInWithUsernameInBackground:username password:@"asdf" block:^(PFUser *user, NSError *error) {
        PFQuery *userRollQuery = [UserRoll query];
        [userRollQuery whereKey:@"phoneNumber" equalTo:phoneNumber];
        [userRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                NSLog(@"User was invited to a roll before.. redirecting to choose from list");
                RollChoiceViewController *rollChoiceVC = [[RollChoiceViewController alloc] init];
                [self presentViewController:rollChoiceVC animated:NO completion:nil];
            } else {
                //user not invited but has a currentRoll
                [Roll setCurrentRollFromParseWithBlock:^(NSError *error) {
                    NSLog(@"Getting Current Roll from Parse for currentUser");
                    CameraViewController *cameraVC = [[CameraViewController alloc] init];
                    [self presentViewController:cameraVC animated:NO completion:nil];
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
                            [self presentViewController:rollChoiceVC animated:NO completion:nil];
                        } else {
                            [Roll createRollWithBlock:^(NSError *error) {
                                SplashViewController *splashVC = [[SplashViewController alloc] init];
                                [self presentViewController:splashVC animated:NO completion:nil];
                            }];
                        }
                    }
                }];
            }];

        }
    }];
}

- (void)setupGPUImageBlurView {
    self.gpuImageVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.gpuImageVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    blurFilter.blurRadiusInPixels = 40.0;
    [self disableAutoFocus];
    
    [self.blurCamera addSubview:filteredVideoView];
    [self.gpuImageVideoCamera addTarget:blurFilter];
    [blurFilter addTarget:filteredVideoView];
    
    [self.gpuImageVideoCamera startCameraCapture];
}

- (void)disableAutoFocus {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device setFlashMode:AVCaptureFlashModeOff];
    
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error;
    for (AVCaptureDevice *device in devices) {
        if (([device hasMediaType:AVMediaTypeVideo]) &&
            ([device position] == AVCaptureDevicePositionBack) ) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                if (device.focusMode == AVCaptureFocusModeLocked) {
                    device.focusMode = AVCaptureFocusModeLocked;
                    NSLog(@"Focus locked");
                } else {
                    device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                     NSLog(@"Focus unlocked");
                }
            }
            [device unlockForConfiguration];
        }
    }
}

@end

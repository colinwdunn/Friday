//
//  SplashViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/17/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SplashViewController.h"
#import "PostSplashViewController.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "RollViewController.h"
#import "FridayCamera.h"
#import "UIImage+Resize.h"
#import "UIImage+ImageEffects.h"
#import <ImageIO/CGImageProperties.h>
#import "Photo.h"
#import <Realm/Realm.h>
#import "CachedBlurredImage.h"

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) NSNumber *rollCount;
@property (nonatomic) FridayCamera *camera;

- (IBAction)onTakePhotoButton:(id)sender;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Style Photo button
    self.takePhotoButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.takePhotoButton.layer.borderWidth = 3;
    self.takePhotoButton.layer.cornerRadius = 20;
    
    //Setup AVCaptureSession for input video feed as background, and output still image
    [[FridayCamera sharedCameraInstance] initCameraSessionWithView:self];

}

#pragma mark - Private methods

- (IBAction)onTakePhotoButton:(id)sender {
    __weak typeof(self) weakself = self;
    [[FridayCamera sharedCameraInstance] photoOnCompletion:^(UIImage *takenPhoto, NSData *photoData) {
        [weakself showImage:takenPhoto];
        [Photo createPhoto:takenPhoto];
    }];
}

- (void)showImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [Photo processImage:image inView:self.view completion:^(UIImage *image, UIImage *processedImage) {
            [CachedBlurredImage saveBlurredImage:processedImage];
            PostSplashViewController *postVC = [[PostSplashViewController alloc] initWithImage:image processedImage:processedImage];
            [self presentViewController:postVC animated:NO completion:nil];
        }];
    });
}

@end

//
//  SplashViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/17/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SplashViewController.h"
#import "PostSplashViewController.h"
#import "UIImage+ImageEffects.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>
#import "RollViewController.h"
#import "FridayCamera.h"
#import "UIImage+Resize.h"

//static NSInteger MaxNumberOfPhotosInRoll = 2;

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) NSNumber *rollCount;
@property (nonatomic) FridayCamera *camera;

@property (nonatomic, strong) PostSplashViewController *vc;

- (IBAction)onTakePhotoButton:(id)sender;
- (void)processImage:(UIImage *)image completion:(void (^)(UIImage *image, UIImage *processedImage))completion;

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Style Photo button
    self.takePhotoButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.takePhotoButton.layer.borderWidth = 3;
    self.takePhotoButton.layer.cornerRadius = 20;
    
    //Setup AVCaptureSession for input video feed as background, and output still image
    self.camera = [[FridayCamera alloc] init];
    [self.camera startRunningCameraSessionWithView:self];

}

#pragma mark - Private methods

- (void)processImage:(UIImage *)image completion:(void (^)(UIImage *image, UIImage *processedImage))completion {
    
    UIImage *resizedImage = [image resizedImage:self.view.frame.size interpolationQuality:kCGInterpolationLow];
    UIImage *processedImage = [resizedImage applyBlurWithRadius:20 tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        completion(image, processedImage);
    });
}

- (IBAction)onTakePhotoButton:(id)sender {
    
    __weak typeof(self) weakself = self;
    
    [self.camera photoOnCompletion:^(UIImage *takenPhoto, NSData *photoData) {
        [weakself showImage:takenPhoto];
        
        NSData *imageData = UIImageJPEGRepresentation(takenPhoto, 0.5f);
        PFFile *imageFile = [PFFile fileWithData:imageData];
        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
        photo[@"imageName"] = @"My trip to Hawaii!";
        photo[@"roll"] = [Roll currentRoll];
        photo[@"imageFile"] = imageFile;
        
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"image saved");
                [Roll setCurrentRollWithBlock:^(NSError *error) {
                    NSLog(@"Current Roll is set");
                }];
            }
        }];

    }];
}

- (void)showImage:(UIImage *)image {
    __weak typeof(self) weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [weakself processImage:image completion:^(UIImage *image, UIImage *processedImage) {
            PostSplashViewController *postVC = [[PostSplashViewController alloc] initWithImage:image processedImage:processedImage];
            self.vc = postVC;
            [self presentViewController:self.vc animated:NO completion:nil];
        }];
    });
}

@end

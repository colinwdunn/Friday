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

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet VLBCameraView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

- (IBAction)onTakePhotoButton:(id)sender;
- (void)processImage:(UIImage *)image completion:(void (^)(UIImage *image, UIImage *processedImage))completion;

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cameraView.delegate = self;
    
    self.takePhotoButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.takePhotoButton.layer.borderWidth = 3;
    self.takePhotoButton.layer.cornerRadius = 20;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma VLBCameraView delegate methods

-(void)cameraView:(VLBCameraView*)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary*)info meta:(NSDictionary *)meta {
    self.takePhotoButton.enabled = YES;
    
    NSLog(@"info: %@", info);
    NSLog(@"meta: %@", meta);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self processImage:image completion:^(UIImage *image, UIImage *processedImage) {
            PostSplashViewController *vc = [[PostSplashViewController alloc] initWithImage:image processedImage:processedImage];
            [self presentViewController:vc animated:NO completion:nil];
        }];
    });
}

-(void)cameraView:(VLBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error {
    self.takePhotoButton.enabled = YES;
}

#pragma mark - Private methods

- (void)processImage:(UIImage *)image completion:(void (^)(UIImage *image, UIImage *processedImage))completion {
    UIImage *processedImage = nil; // [image applyExtraLightEffect];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(image, processedImage);
    });
}

- (IBAction)onTakePhotoButton:(id)sender {
    [self.cameraView takePicture];
    
    self.takePhotoButton.enabled = NO;
}

@end

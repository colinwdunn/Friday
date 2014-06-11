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
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

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
    
    
    self.takePhotoButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.takePhotoButton.layer.borderWidth = 3;
    self.takePhotoButton.layer.cornerRadius = 20;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = self.view.layer;
    rootLayer.masksToBounds = YES;
    previewLayer.frame = CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height);
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey,nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:self.stillImageOutput];
    
    [session startRunning];
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
    //[self.cameraView takePicture];
    
    self.takePhotoButton.enabled = NO;
}

@end

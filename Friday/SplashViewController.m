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


static NSInteger MaxNumberOfPhotosInRoll = 2;

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) NSNumber *rollCount;
@property (nonatomic, strong) NSMutableArray* photoArray;

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
    [self startCameraLiveFeed];
    
    //initalize photo array
    if (self.photoArray == nil) {
        self.photoArray = [NSMutableArray array];
    }

}

#pragma mark - AVFoundation methods

- (void)startCameraLiveFeed {
    
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

#pragma mark - Private methods

- (void)processImage:(UIImage *)image completion:(void (^)(UIImage *image, UIImage *processedImage))completion {
    
    //TODO (Joe): Figure out how to process the image and add blur
    UIImage *processedImage = nil; // [image applyExtraLightEffect];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        completion(image, processedImage);
    });
}

- (IBAction)onTakePhotoButton:(id)sender {
    
    //TODO: Refactor code so it is simpler
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    
    __weak typeof(self) weakself = self;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        
        if (exifAttachments) {
            // Do something with the attachments
            NSLog(@"attachments: %@", exifAttachments);
        } else {
            // No attachments
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        
        [weakself showImage:image];
        
        PFFile *imageFile = [PFFile fileWithData:imageData];
        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
        photo[@"imageName"] = @"My trip to Hawaii!";
        photo[@"imageFile"] = imageFile;
        
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [weakself downloadImages];
        }];
    
       // weakself.takePhotoButton.enabled = NO;
    }];
}

- (void)showImage:(UIImage *)image {
    __weak typeof(self) weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [weakself processImage:image completion:^(UIImage *image, UIImage *processedImage) {
            PostSplashViewController *vc = [[PostSplashViewController alloc] initWithImage:image processedImage:processedImage];
            self.vc = vc;
            [self presentViewController:self.vc animated:NO completion:nil];
        }];
    });
}

- (void)downloadImages {

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    __weak typeof(self) weakself = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [weakself setRollCount:[NSNumber numberWithInteger:objects.count]];
                if ([self.rollCount integerValue] >= MaxNumberOfPhotosInRoll) {
                    for (PFObject *object in objects) {
                        if (object != nil) {
                            [weakself.photoArray addObject:object];
                        }
                    }
                    [weakself developRoll:weakself.photoArray];
                }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)developRoll: (NSArray*)photoArray {
    [self.vc dismissViewControllerAnimated:YES completion:^ {
        RollViewController *rollvc = [[RollViewController alloc] initWithNibName:@"RollViewController" bundle:nil];
        rollvc.photosArray = self.photoArray;
        [self presentViewController:rollvc animated:YES completion:nil];
     }];
    
}


@end

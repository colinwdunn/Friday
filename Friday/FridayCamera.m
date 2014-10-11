//
//  FridayCamera.m
//  Friday
//
//  Created by Joseph Anderson on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "FridayCamera.h"


@interface FridayCamera()

@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureSession *cameraSession;

@end

@implementation FridayCamera

static FridayCamera *sharedFridayCamera = nil;

+ (id)sharedCameraInstance {
    if (sharedFridayCamera == nil) {
        sharedFridayCamera = [[self alloc] init];
    }
    return sharedFridayCamera;
}

- (void)initCameraSessionWithView:(UIViewController *)viewController {
    self.cameraSession = [[AVCaptureSession alloc] init];
    self.cameraSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([self.cameraSession canAddInput:deviceInput]) {
        [self.cameraSession addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = viewController.view.layer;
    rootLayer.masksToBounds = YES;
    previewLayer.frame = CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height);
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey,nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.cameraSession addOutput:self.stillImageOutput];
    
    [self startRunningCameraSession];

}

- (void)startRunningCameraSession{
    NSLog(@"Camera Session Started");
    [self.cameraSession startRunning];
}

- (void)stopRunningCameraSession{
    NSLog(@"Camera Session Stopped");
    [self.cameraSession stopRunning];
}


- (void)photoOnCompletion:(void (^)(UIImage *takenPhoto, NSData *photoData))onCompletion {
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
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        
        if (exifAttachments) {
            // Do something with the attachments
            //NSLog(@"attachments: %@", exifAttachments);
        } else {
            // No attachments
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        onCompletion(image, imageData);
        
    }];
    
}


@end

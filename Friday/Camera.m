//
//  Camera.m
//  Friday
//
//  Created by Joseph Anderson on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Camera.h"

@interface Camera()

@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation Camera

- (void)startRunningCameraSessionWithView:(UIViewController *)viewController {
    
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
    
    CALayer *rootLayer = viewController.view.layer;
    rootLayer.masksToBounds = YES;
    previewLayer.frame = CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height);
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey,nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:self.stillImageOutput];
    
    [session startRunning];
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
            NSLog(@"attachments: %@", exifAttachments);
        } else {
            // No attachments
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        onCompletion(image, imageData);
        
    }];

}

//- (void)downloadImages {
//    
//    if (self.photoArray == nil) {
//        self.photoArray = [NSMutableArray array];
//    }
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"photo"];
//    __weak typeof(self) weakself = self;
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %lu images.", (unsigned long)objects.count);
//            
//            [weakself setRollCount:[NSNumber numberWithInteger:objects.count]];
//            
//            if ([self.rollCount integerValue] >= MaxNumberOfPhotosInRoll) {
//                for (PFObject *object in objects) {
//                    NSLog(@"%@", object.objectId);
//                    
//                    PFFile *imageFile = [object objectForKey:@"imageFile"];
//                    NSData *data = [imageFile getData];
//                    UIImage *image = [UIImage imageWithData:data];
//                    
//                    if (image != nil) {
//                        [weakself.photoArray addObject:image];
//                    }
//                    
//                }
//                
//                [weakself developRoll:weakself.photoArray];
//            }
//        } else {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//}
//
//- (void)developRoll: (NSArray*)photoArray {
//    //TODO: optamize.
//    [self.vc dismissViewControllerAnimated:YES completion:^ {
//        RollViewController *rollvc = [[RollViewController alloc] initWithNibName:@"RollViewController" bundle:nil];
//        rollvc.photosArray = self.photoArray;
//        [self presentViewController:rollvc animated:YES completion:nil];
//    }];
//    
//}


@end

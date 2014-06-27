//
//  FridayCamera.h
//  Friday
//
//  Created by Joseph Anderson on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+ImageEffects.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>

@interface FridayCamera : NSObject

- (void)startRunningCameraSessionWithView:(UIViewController *)viewController;
- (void)photoOnCompletion:(void (^)(UIImage *takenPhoto, NSData *photoData))onCompletion;

@end

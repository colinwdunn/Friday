//
//  Photo.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Photo.h"
#import "UIImage+Resize.h"
#import "UIImage+ImageEffects.h"
#import <Parse/PFObject+Subclass.h>

@implementation Photo

@dynamic imageName;
@dynamic photoURL;
@dynamic imageFile;
@dynamic user;
@dynamic roll;

+ (NSString *)parseClassName {
    return @"Photo";
}

+ (void)createPhoto:(UIImage *)orignalPhoto {
    NSData *smallerImageData = UIImageJPEGRepresentation(orignalPhoto, 0.5f);
    PFFile *imageFile = [PFFile fileWithData:smallerImageData];
    Photo *photo = [[Photo alloc] init];
    photo.imageName = @"My trip to Hawaii!";
    photo.roll = [Roll currentRoll];
    photo.imageFile = imageFile;
    
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Photo file was uploaded");
        [Roll updatePhotoCountForCurrentRollWithBlock:^(NSError *error) {
            
        }];
    }];
}

//resizes and blurs the captured image
+ (void)processImage:(UIImage *)image inView:(UIView *)currentView completion:(void (^)(UIImage *image, UIImage *processedImage))completion {
    UIImage *resizedImage = [image resizedImage:currentView.frame.size interpolationQuality:kCGInterpolationLow];
    UIImage *processedImage = [resizedImage applyBlurWithRadius:20 tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
    dispatch_async(dispatch_get_main_queue(), ^ {
        completion(image, processedImage);
    });
}

@end

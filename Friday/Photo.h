//
//  Photo.h
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Roll.h"

@interface Photo : PFObject <PFSubclassing>

@property NSString *imageName;
@property NSString *photoURL;
@property PFFile *imageFile;
@property User* user;
@property Roll* roll;


+ (NSString *)parseClassName;
+ (void)createPhoto:(UIImage *)orignalPhoto;
+ (void)processImage:(UIImage *)image inView:(UIView *)currentView completion:(void (^)(UIImage *image, UIImage *processedImage))completion;
@end

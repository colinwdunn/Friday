//
//  Roll.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Roll.h"
#import <Parse/PFObject+Subclass.h>

@implementation Roll

@dynamic rollName;
@dynamic rollId;
@dynamic ownerId;
@dynamic maxPhotos;
@dynamic photosCount;

+ (NSString *)parseClassName{
    return @"Roll";
}

//- (UIImageView *)photoFile {
//    PFImageView *imageView = [[PFImageView alloc] init];
//    imageView.file = self.photosFile;
//    [imageView loadInBackground];
//    return
//}





@end

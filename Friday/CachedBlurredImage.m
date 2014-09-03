//
//  CachedBlurredImage.m
//  Friday
//
//  Created by Yousra Kamoona on 8/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "CachedBlurredImage.h"

@implementation CachedBlurredImage

+ (void)saveBlurredImage:(UIImage *)processedImage {
    NSData *cachedBlurredImageData =  UIImageJPEGRepresentation(processedImage, 0.5f);
    CachedBlurredImage *cachedBlurredImage = [[CachedBlurredImage alloc] init];
    cachedBlurredImage.blurredImage = cachedBlurredImageData;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:cachedBlurredImage];
    [realm commitWriteTransaction];
}

+ (UIImage *)getBlurredImage {
    RLMArray *blurredImages = [CachedBlurredImage allObjects];
    CachedBlurredImage *cachedBlurredImage = blurredImages[0];
    UIImage *blurredImageDisplay = [UIImage imageWithData:cachedBlurredImage.blurredImage];
    return blurredImageDisplay;
}
@end

//
//  CachedBlurredImage.h
//  Friday
//
//  Created by Yousra Kamoona on 8/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface CachedBlurredImage : RLMObject

@property (nonatomic, strong) NSData *blurredImage;

+ (void)saveBlurredImage: (UIImage *)processedImage;
+ (UIImage *)getBlurredImage;
@end

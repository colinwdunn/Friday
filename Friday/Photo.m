//
//  Photo.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Photo.h"
#import <Parse/PFObject+Subclass.h>

@implementation Photo

+ (NSString *)parseClassName {
    return @"Photo";
}

@dynamic user;
@dynamic roll;
@dynamic photoURL;


@end

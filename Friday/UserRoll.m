//
//  UserRoll.m
//  Friday
//
//  Created by Yousra Kamoona on 7/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UserRoll.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserRoll

@dynamic roll;
@dynamic user;
@dynamic phoneNumber;
@dynamic invitedUserName;
@dynamic status;

+ (NSString *)parseClassName {
    return @"UserRoll";
}

@end

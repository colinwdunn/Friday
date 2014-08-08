//
//  User.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "User.h"
#import <Parse/PFObject+Subclass.h>

@implementation User

@dynamic username;
@dynamic firstName;
@dynamic phoneNumber;
@dynamic currentRoll;

@end


//- (id)initWithPFObject:(PFObject *)PFObjectUser{
//    self.userId = PFObjectUser.objectId;
//    self.firstName = PFObjectUser[@"username"];
//    return self;
//}
//

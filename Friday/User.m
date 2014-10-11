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

+ (void)saveCurrentRoll:(Roll *)roll toCurrentUserWithBlock:(void (^)(NSError *))block {
    [User currentUser].currentRoll = roll;
    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Current Roll saved to Current User");
        block(error);
    }];
}

@end
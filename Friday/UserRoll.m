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
//281-249-9718
+ (void)getInvitedToRollsWithBlock: (void (^) (NSError *error, NSArray *invitedToRolls))block {
    NSMutableArray *invitedToRolls = [NSMutableArray array];
    PFQuery *getInvitedToRolls = [UserRoll query];
    [getInvitedToRolls whereKey:@"phoneNumber" equalTo:[User currentUser].phoneNumber];
    [getInvitedToRolls includeKey:@"roll"];
    [getInvitedToRolls findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserRoll *userRoll in objects) {
            [invitedToRolls addObject:userRoll.roll];
        }
        block(error, invitedToRolls);
    }];
}

+ (void)updateRoll:(Roll*)roll StatusToAcceptedWithBlock:(void (^) (NSError *error))block {
    PFQuery *getInvitedToRolls = [UserRoll query];
    [getInvitedToRolls includeKey:@"roll"];
    [getInvitedToRolls whereKey:@"roll" equalTo:[Roll currentRoll]];
    [getInvitedToRolls whereKey:@"invitedUserName" equalTo:[User currentUser].username];
    [getInvitedToRolls getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        UserRoll *userRoll = (UserRoll *)object;
        userRoll.status = @"accepted";
        [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Roll Status Changed to accpeted");
        }];
        block(error);
    }];
}

@end
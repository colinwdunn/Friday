//
//  UserRoll.h
//  Friday
//
//  Created by Yousra Kamoona on 7/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>
#import "Roll.h"
#import "User.h"

@interface UserRoll : PFObject <PFSubclassing>

@property (nonatomic, strong) Roll *roll;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *invitedUserName;
@property (nonatomic, strong) NSString *status;

+ (NSString *)parseClassName;
+ (void)getInvitedToRollsWithBlock: (void (^) (NSError *error, NSArray *invitedToRolls))block;
+ (void)updateRoll:(Roll*)roll StatusToAcceptedWithBlock:(void (^) (NSError *error))block;
@end

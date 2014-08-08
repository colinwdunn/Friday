//
//  User.h
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>

@class Roll;

@interface User : PFUser <PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) Roll *currentRoll;

//- (id)initWithPFObject:(PFObject *)PFObjectUser;

//- (void)getInvitedUser:(NSMutableArray *)invitedUsers  withSuccess:(void (^) (User *invitedUser))successBlock andFailure: (void (^) (NSError *error))failureBlock;

@end

//
//  User.h
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser <PFSubclassing>

@property (nonatomic) NSString *userId;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *emailBaby;
@property (nonatomic, strong) NSString *phoneNumber;

- (id)initWithPFObject:(PFObject *)PFObjectUser;

- (void)getInvitedUser:(NSMutableArray *)invitedUsers  withSuccess:(void (^) (User *invitedUser))successBlock andFailure: (void (^) (NSError *error))failureBlock;

@end

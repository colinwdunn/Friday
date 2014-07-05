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

- (id)initWithPFObject:(PFObject *)PFObjectUser{
    self.userId = PFObjectUser.objectId;
    self.firstName = PFObjectUser[@"username"];
    return self;
}

- (void)getInvitedUser:(NSMutableArray *)invitedUsers  withSuccess:(void (^) (User *invitedUser))successBlock andFailure: (void (^) (NSError *error))failureBlock {
    PFQuery *fetchInvitedUser = [User query];
    [fetchInvitedUser whereKey:@"username" equalTo:@"Joseph Anderson"];
    
    [fetchInvitedUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            //User *invitedUser = [[User alloc] initWithPFObject:[objects  firstObject]];
            successBlock([objects firstObject]);
        } else {
            failureBlock(error);
        }
    }];
}

@end

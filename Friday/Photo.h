//
//  Photo.h
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Roll.h"

@interface Photo : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property User* user;
@property Roll* roll;
@property NSString *photoURL;

@end

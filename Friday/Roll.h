//
//  Roll.h
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"

@interface Roll : PFObject <PFSubclassing>

@property NSString *rollId;
@property NSInteger maxPhotos;
@property NSInteger photosCount;
@property NSString *userId;
@property NSString *rollName;
@property (readonly) NSInteger photosRemaining;

+ (NSString *)parseClassName;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)decodeWithCoder:(NSCoder *)decoder;


+ (void)createRollWithBlock: (void (^) (NSError *error))block;
//+ (void)setCurrentRollFromUserRollWithBlock: (void (^) (NSError *error))block;
+ (void)getNumberOfMembersInRollWithBlock:(void (^) (NSInteger membersNumber, NSError *error))block;
+ (void)setCurrentRollFromParseWithBlock: (void (^) (NSError *error))block;
+ (void)setCurrentRoll:(Roll *)roll;
+ (void)updatePhotoCountForCurrentRollWithBlock:(void (^) (NSError *error))block;
+ (Roll *)currentRoll;
+ (void)getRollPhotosWithBlock:(void (^) (NSError *error, NSArray *photosArray))block;
@end

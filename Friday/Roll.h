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

+ (NSString *)parseClassName;
- (id)initWithPFObject:(PFObject *)PFObjectRoll;
- (void)getCurrentRoll:(User *)currentUser withSuccess:(void (^) (Roll *currentRoll))successBlock andFailure:(void (^) (NSError *error))failureBlock;

+ (Roll *)currentRoll;

@property (nonatomic, strong) User *rollOwner;
@property (nonatomic, weak) NSString *rollId;
@property (nonatomic, strong) NSString *rollName;
@property int maxPhotos;
@property int photosCount;
@property (readonly) int photosRemaining;

@end
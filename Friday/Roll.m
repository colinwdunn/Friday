//
//  Roll.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Roll.h"
#import <Parse/PFObject+Subclass.h>

static Roll *currentRoll = nil;

@implementation Roll

@dynamic rollId;
@dynamic rollName;
@dynamic maxPhotos;
@dynamic photosCount;

+ (NSString *)parseClassName{
    return @"Roll";
}

- (id)initWithPFObject:(PFObject *)PFObjectRoll{
    self.rollId = PFObjectRoll.objectId;
    self.rollOwner = PFObjectRoll[@"user"];
    return self;
}

- (void)getCurrentRoll:(User *)currentUser withSuccess:(void (^) (Roll *currentRoll))successBlock andFailure:(void (^) (NSError *error))failureBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"UserRolls"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:currentUser];
    [query includeKey:@"roll"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            if (!error) {
                Roll *currentRoll = [[Roll alloc] init];
                currentRoll = [[objects firstObject] objectForKey:@"roll"];
                successBlock(currentRoll);
            } else {
                failureBlock(error);
            }
        } else {
            Roll *newRoll = [Roll object];
            newRoll[@"user"] = [User currentUser];
            [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    PFObject *parseObjectRoll = [PFObject objectWithClassName:@"UserRolls"];
                    parseObjectRoll[@"user"] = [PFUser currentUser];
                    parseObjectRoll[@"roll"] = newRoll;
                    parseObjectRoll[@"status"] = @"accepted";
                [parseObjectRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    successBlock(newRoll);
                }];
                
            }];
            
            
            // Create a new roll
            // Create new row in UserRolls table
        }
    }];
}

+ (Roll *)currentRoll {
    if (currentRoll == nil) {
        PFQuery *fetchLastRoll = [PFQuery queryWithClassName:@"UserRolls"];
        [fetchLastRoll whereKey:@"user" equalTo:[PFUser currentUser]];
        [fetchLastRoll orderByDescending:@"createdAt"];
        [fetchLastRoll includeKey:@"roll"];
        [fetchLastRoll getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object != nil) {
                PFObject *parseObjectRoll = [object objectForKey:@"roll"];
                currentRoll = [[Roll alloc] initWithPFObject:parseObjectRoll];
            } else {
                // Create a new roll
                PFObject *firstRoll = [PFObject objectWithClassName:@"Roll"];
                firstRoll[@"user"] = [PFUser currentUser];
                [firstRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    PFObject *userRoll = [PFObject objectWithClassName:@"UserRolls"];
                    userRoll[@"user"] = [PFUser currentUser];
                    userRoll[@"roll"] = firstRoll;
                    userRoll[@"status"] = @"accepted";
                    [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        currentRoll = [[Roll alloc] initWithPFObject:firstRoll];
                    }];
                }];
                
            }

        }];
    }
    return currentRoll;
}
//- (UIImageView *)photoFile {
//    PFImageView *imageView = [[PFImageView alloc] init];
//    imageView.file = self.photosFile;
//    [imageView loadInBackground];
//    return
//}





@end

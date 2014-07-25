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
@dynamic photosRemaining;

+ (NSString *)parseClassName{
    return @"Roll";
}

- (id)initWithPFObject:(PFObject *)PFObjectRoll{
    self.rollId = PFObjectRoll.objectId;
    self.rollOwner = PFObjectRoll[@"user"];
    return self;
}


- (void)getInvitedToRoll {
    
    PFQuery *inviteCheckQuery = [PFQuery queryWithClassName:@"UserRolls"];
    [inviteCheckQuery orderByDescending:@"createdAt"];
    [inviteCheckQuery whereKey:@"invitedUsername" equalTo:[User currentUser].username];
    [inviteCheckQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            PFObject *userRoll = [objects firstObject];
            userRoll[@"user"] = [User currentUser];
            [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self getCurrentRoll:[User currentUser] withSuccess:^(Roll *currentRoll) {
                    [User currentUser].currentRoll = currentRoll;
                    [[User currentUser] saveInBackground];
                    NSLog(@"Succeeded");
                } andFailure:^(NSError *error) {
                    NSLog(@"Failed");
                }];
            }];
        } else {
            [self getCurrentRoll:[User currentUser] withSuccess:^(Roll *currentRoll) {
                [User currentUser].currentRoll = currentRoll;
                [[User currentUser] saveInBackground];
                NSLog(@"Succeeded2");
            } andFailure:^(NSError *error) {
                NSLog(@"Failed2");
            }];
        }
    }];
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
                [User currentUser].currentRoll = currentRoll;
                [[User currentUser] saveInBackground];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:currentRoll.objectId forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                successBlock(currentRoll);
            } else {
                failureBlock(error);
            }
        } else {
            Roll *newRoll = [Roll object];
            newRoll[@"user"] = [User currentUser];
            newRoll[@"photosCount"] = @(0);
            newRoll[@"maxPhotos"] = @(6);
            [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    PFObject *parseObjectRoll = [PFObject objectWithClassName:@"UserRolls"];
                    parseObjectRoll[@"user"] = [PFUser currentUser];
                    parseObjectRoll[@"roll"] = newRoll;
                    parseObjectRoll[@"status"] = @"accepted";
                [parseObjectRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [User currentUser].currentRoll = currentRoll;
                    [[User currentUser] saveInBackground];
                    successBlock(newRoll);
                }];
                
            }];
        }
    }];
}

+ (Roll *)currentRoll {
    return [User currentUser].currentRoll;
//    if (currentRoll == nil) {
//        PFQuery *fetchLastRoll = [PFQuery queryWithClassName:@"UserRolls"];
//        [fetchLastRoll whereKey:@"user" equalTo:[PFUser currentUser]];
//        [fetchLastRoll orderByDescending:@"createdAt"];
//        [fetchLastRoll includeKey:@"roll"];
//        [fetchLastRoll getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            if (object != nil) {
//                PFObject *parseObjectRoll = [object objectForKey:@"roll"];
//                currentRoll = [[Roll alloc] initWithPFObject:parseObjectRoll];
//            } else {
//                // Create a new roll
//                PFObject *firstRoll = [PFObject objectWithClassName:@"Roll"];
//                firstRoll[@"user"] = [PFUser currentUser];
//                [firstRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    PFObject *userRoll = [PFObject objectWithClassName:@"UserRolls"];
//                    userRoll[@"user"] = [PFUser currentUser];
//                    userRoll[@"roll"] = firstRoll;
//                    userRoll[@"status"] = @"accepted";
//                    [userRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                        currentRoll = [[Roll alloc] initWithPFObject:firstRoll];
//                    }];
//                }];
//                
//            }
//
//        }];
//    }
//    return currentRoll;
}
//- (UIImageView *)photoFile {
//    PFImageView *imageView = [[PFImageView alloc] init];
//    imageView.file = self.photosFile;
//    [imageView loadInBackground];
//    return
//}

- (int)photosRemaining {
    return self.maxPhotos - self.photosCount;
}



@end

//
//  Roll.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Roll.h"
#import "UserRoll.h"
#import "Photo.h"
#import <Parse/PFObject+Subclass.h>

static Roll *_currentRoll = nil;
const NSInteger kMaxPhotos = 6;

@implementation Roll

@dynamic rollId;
@dynamic maxPhotos;
@dynamic photosCount;
@dynamic userId;
@dynamic rollName;

+ (NSString *)parseClassName{
    return @"Roll";
}

- (NSInteger)photosRemaining {
    return self.maxPhotos - self.photosCount;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.maxPhotos = [decoder decodeIntegerForKey:@"maxPhotos"];
        self.photosCount = [decoder decodeIntegerForKey:@"photosCount"];
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.rollId = [decoder decodeObjectForKey:@"rollId"];
        self.objectId = [decoder decodeObjectForKey:@"objectId"];
    }
    return self;
}

- (id)decodeWithCoder:(NSCoder *)decoder {
    self.maxPhotos = [decoder decodeIntegerForKey:@"maxPhotos"];
    self.photosCount = [decoder decodeIntegerForKey:@"photosCount"];
    self.userId = [decoder decodeObjectForKey:@"userId"];
    self.rollId = [decoder decodeObjectForKey:@"rollId"];
    self.objectId = [decoder decodeObjectForKey:@"objectId"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.maxPhotos forKey:@"maxPhotos"];
    [encoder encodeInteger:self.photosCount forKey:@"photosCount"];
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.rollId forKey:@"rollId"];
    [encoder encodeObject:self.objectId forKey:@"objectId"];
}


+ (void)createRollWithBlock: (void (^) (NSError *error))block {
    Roll *newRoll = [[Roll alloc] init];
    newRoll.photosCount = 0;
    newRoll.maxPhotos = kMaxPhotos;
    newRoll.userId = [User currentUser].objectId;
    newRoll.rollName = @"My Trip Not To Hawaii";
    [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [User saveCurrentRoll:newRoll toCurrentUserWithBlock:^(NSError *error) {
            [Roll setCurrentRoll:newRoll];
            NSLog(@"Roll was created and saved to current User on Parse and saved in UserDefaults.");
            block(error);
            UserRoll *userRoll = [[UserRoll alloc] init];
            userRoll.invitedUserName = User.currentUser.username;
            userRoll.status = @"Owner";
            userRoll.phoneNumber = User.currentUser.phoneNumber;
            userRoll.roll = newRoll;
            userRoll.user = User.currentUser;
            [userRoll saveInBackground];
        }];
    }];
}

+ (void)setCurrentRoll:(Roll *)roll {
    _currentRoll = roll;
    NSData *currentRollData = [NSKeyedArchiver archivedDataWithRootObject:_currentRoll];
    NSUserDefaults *currentRoll = [NSUserDefaults standardUserDefaults];
    [currentRoll setObject:currentRollData forKey:@"CurrentRoll"];
    [currentRoll synchronize];
}

+ (void)updatePhotoCountForCurrentRollWithBlock:(void (^) (NSError *error))block {
    PFQuery *updateRollPhotoCount = [Roll query];
    [updateRollPhotoCount getObjectInBackgroundWithId:[Roll currentRoll].objectId block:^(PFObject *object, NSError *error) {
        NSLog(@"On Device Current roll count: %ld", (long)(_currentRoll).photosCount);
        NSLog(@"From Parse Current roll count: %ld", (long)((Roll *)object).photosCount);
        _currentRoll = (Roll *)object;
        _currentRoll.photosCount++;
        [_currentRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [Roll setCurrentRoll:_currentRoll];
            NSLog(@"New current roll count: %ld", (long)_currentRoll.photosCount);
            NSLog(@"Photo count for current roll is updated.");
                block(error);
            }];
        }];
}

+ (void)getNumberOfMembersInRollWithBlock:(void (^) (NSInteger membersNumber, NSError *error))block {
    PFQuery *memberQuery = [UserRoll query];
    [memberQuery whereKey:@"roll" equalTo:[Roll currentRoll]];
    [memberQuery whereKey:@"status" equalTo:@"accepted"];
    [memberQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSInteger memberNumber = objects.count + 1;
        block(memberNumber, error);
    }];
}

+ (void)getMembersListInRollWithBlock: (void (^) (NSArray *membersArray, NSError *error))block {
    PFQuery *memberQuery = [UserRoll query];
    [memberQuery whereKey:@"roll" equalTo:[Roll currentRoll]];
    [memberQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *members = [[NSArray alloc] initWithArray:objects];
        block(members, error);
    }];
}

//when app is deleted (current roll not on device anymore). On retrun, get current roll from parse.
+ (void)setCurrentRollFromParseWithBlock:(void (^) (NSError *error))block {
    if (_currentRoll == nil) {
        PFQuery *currentUserQuery = [User query];
        [currentUserQuery includeKey:@"currentRoll"];
        [currentUserQuery getObjectInBackgroundWithId:[User currentUser].objectId block:^(PFObject *object, NSError *error) {
                _currentRoll = [(User *)object currentRoll];
                [Roll setCurrentRoll:_currentRoll];
                block(error);
        }];
    }
}

//Getting current roll from NSUserDefaults
+ (Roll *)currentRoll {
    if (_currentRoll == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:@"CurrentRoll"];
        _currentRoll = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    return _currentRoll;
}

//Retrieve all the images for the currentRoll
+ (void)getRollPhotosWithBlock:(void (^) (NSError *error, NSArray *photosArray))block {
    PFQuery *query = [Photo query];
    [query whereKey:@"roll" equalTo:[Roll currentRoll]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(error, objects);
    }];
}

@end


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

//281-249-9718
//Jim: 5742655062

//#define kUserNameValue @"serNameKey" > Have a constant.h/.m file for these and import them when needed

static Roll *_currentRoll = nil;
const NSInteger kMaxPhotos = 6;

@implementation Roll

@dynamic rollId;
@dynamic maxPhotos;
@dynamic photosCount;
@dynamic userId;
//@dynamic photosRemaining;


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
    [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [User saveCurrentRoll:newRoll toCurrentUserWithBlock:^(NSError *error) {
            [Roll setCurrentRoll:newRoll];
            NSLog(@"Roll was created and saved to current User on Parse and saved in UserDefaults.");
            block(error);
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

+ (void)setCurrentRollFromUserRollWithBlock: (void (^) (NSError *error))block {
    PFQuery *invitedToRollQuery = [UserRoll query];
    [invitedToRollQuery includeKey:@"roll"];
    [invitedToRollQuery whereKey:@"invitedUserName" equalTo:[User currentUser].username];
    [invitedToRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _currentRoll = [(UserRoll *)objects[0] roll];
        _currentRoll.photosCount ++;
        [User currentUser].currentRoll = _currentRoll;
        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [Roll setCurrentRoll:_currentRoll];
                block(error);
            }];
        }];
}

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

//DO: initialize default values (in AppDelegate, NSDictionary* defaults = @{kUserNameKey:@"GreatUser", kLevel1ScoreKey:@0, kLevel1CompletedKey:@NO};
//[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];


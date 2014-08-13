//
//  Roll.m
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Roll.h"
#import "UserRoll.h"
#import <Parse/PFObject+Subclass.h>

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
        //self.photosRemaining = [decoder decodeIntegerForKey:@"photosRemaining"];
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
}

+ (void)updatePhotoCountForCurrentRollWithBlock:(void (^) (NSError *error))block {
    PFQuery *updateRollPhotoCount = [Roll query];
    [updateRollPhotoCount getObjectInBackgroundWithId:[Roll currentRoll].objectId block:^(PFObject *object, NSError *error) {
        _currentRoll = (Roll *)object;
        _currentRoll.photosCount ++;
        [Roll setCurrentRoll:_currentRoll];
        [_currentRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
        PFQuery *currentRollQuery = [Roll query];
        [currentRollQuery getObjectInBackgroundWithId:[User currentUser].objectId block:^(PFObject *object, NSError *error) {
            if ([(Roll *)object photosCount] > 0) {
                _currentRoll = (Roll*)object;
                [User currentUser].currentRoll = _currentRoll;
                [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [_currentRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [Roll setCurrentRoll:_currentRoll];
                        block(error);
                    }];
                }];
            } else {
                [Roll createRollWithBlock:^(NSError *error) {
                    NSLog(@"Roll was created.");
                    block(error);
                }];
            }
            
        }];
    }
}

+ (Roll *)currentRoll {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"CurrentRoll"];
    _currentRoll = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return _currentRoll;
}

+ (void)developRollWithBlock:(void (^) (NSError *error, NSArray *photosArray))block {
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"roll" equalTo:[Roll currentRoll]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(error, objects);
    }];
}

@end

//DO: initialize default values (in AppDelegate, NSDictionary* defaults = @{kUserNameKey:@"GreatUser", kLevel1ScoreKey:@0, kLevel1CompletedKey:@NO};
//[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

//+ (void)createRollWithBlock: (void (^) (NSError *error))block {
//    Roll *newRoll = [[Roll alloc] init];
//    newRoll.photosCount = 0;
//    newRoll.maxPhotos = kMaxPhotos;
//    newRoll.userId = [User currentUser].objectId;
//    [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        PFQuery *getObjectWithId = [Roll query];
//        [getObjectWithId getObjectInBackgroundWithId:newRoll.objectId block:^(PFObject *object, NSError *error) {
//            _currentRoll = (Roll*)object;
//            _currentRoll.rollId = _currentRoll.objectId;
//            [_currentRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                [Roll setCurrentRollWithBlock:^(NSError *error) {
//                    NSLog(@"Current Roll is set");
//                }];
//                block(error);
//            }];
//        }];
//    }];
//    
//}

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

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.maxPhotos forKey:@"maxPhotos"];
    [encoder encodeInteger:self.photosCount forKey:@"photosCount"];
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.rollId forKey:@"rollId"];
    [encoder encodeObject:self.objectId forKey:@"objectId"];
    //[encoder encodeInteger:self.photosRemaining forKey:@"photosRemaining"];
}

- (id)decodeWithCoder:(NSCoder *)decoder {
    self.maxPhotos = [decoder decodeIntegerForKey:@"maxPhotos"];
    self.photosCount = [decoder decodeIntegerForKey:@"photosCount"];
    self.userId = [decoder decodeObjectForKey:@"userId"];
    self.rollId = [decoder decodeObjectForKey:@"rollId"];
    self.objectId = [decoder decodeObjectForKey:@"objectId"];
    //self.photosRemaining = [decoder decodeIntegerForKey:@"photosRemaining"];
    return self;
}

- (void)createPhoto:(UIImage *)orignalPhoto {
    // Update counts
    // Save current roll to NSUserDefaults

    NSData *smallerImageData = UIImageJPEGRepresentation(orignalPhoto, 0.5f);
    PFFile *imageFile = [PFFile fileWithData:smallerImageData];

    PFObject *photo = [PFObject objectWithClassName:@"Photo"];
    photo[@"imageName"] = @"My trip to Hawaii!";
    photo[@"roll"] = [Roll currentRoll];
    photo[@"imageFile"] = imageFile;

    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [Roll setCurrentRollWithBlock:^(NSError *error) {
                //[self updatePhotoCountView];
            }];
    }];
}

+ (void)createRollWithBlock: (void (^) (NSError *error))block {
    Roll *newRoll = [[Roll alloc] init];
    newRoll.photosCount = 0;
    newRoll.maxPhotos = kMaxPhotos;
    newRoll.userId = [User currentUser].objectId;
    [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [Roll setCurrentRollWithBlock:^(NSError *error) {
            NSLog(@"Current Roll is set");
            block(error);
        }];
    }];
}

//DO: initialize default values (in AppDelegate, NSDictionary* defaults = @{kUserNameKey:@"GreatUser", kLevel1ScoreKey:@0, kLevel1CompletedKey:@NO};
//[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

+ (void)setCurrentRollFromUserRollWithBlock: (void (^) (NSError *error))block {
    PFQuery *invitedToRollQuery = [UserRoll query];
    [invitedToRollQuery includeKey:@"roll"];
    [invitedToRollQuery whereKey:@"invitedUserName" equalTo:[User currentUser].username];
    [invitedToRollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _currentRoll = [(UserRoll *)objects[0] roll];
        _currentRoll.photosCount += 1;
        [User currentUser].currentRoll = _currentRoll;
        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSData *currentRollData = [NSKeyedArchiver archivedDataWithRootObject:_currentRoll];
                NSUserDefaults *currentRoll = [NSUserDefaults standardUserDefaults];
                [currentRoll setObject:currentRollData forKey:@"CurrentRoll"];
                NSLog(@"set currentRoll for invited user with objectId = %@, and rollId = %@", _currentRoll.objectId, _currentRoll.rollId);
                block(error);
            }];
        }];
}

+ (Roll *)setCurrentRollWithBlock: (void (^) (NSError *error))block {
    //if current roll hasn't been set yet, get it from the roll tabel. (roll here == new created roll)
    if (_currentRoll == nil) {
        PFQuery *currentRollQuery = [Roll query];
        [currentRollQuery getObjectInBackgroundWithId:[User currentUser].objectId block:^(PFObject *object, NSError *error) {
            _currentRoll = (Roll*)object;
            [User currentUser].currentRoll = _currentRoll;
            [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [_currentRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSData *currentRollData = [NSKeyedArchiver archivedDataWithRootObject:_currentRoll];
                    NSUserDefaults *currentRoll = [NSUserDefaults standardUserDefaults];
                    [currentRoll setObject:currentRollData forKey:@"CurrentRoll"];
                    NSLog(@"set currentRoll with objectId = %@, and rollId = %@", _currentRoll.objectId, _currentRoll.rollId);
                    block(error);
                }];
            }];
        }];
    } else {
        //if it is set, update it with the passed roll.
        PFQuery *currentRollQuery = [Roll query];
        [currentRollQuery getObjectInBackgroundWithId:_currentRoll.rollId block:^(PFObject *object, NSError *error) {
            _currentRoll = (Roll*)object;
            _currentRoll.photosCount += 1;
            [User currentUser].currentRoll = _currentRoll;
            [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [_currentRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSData *currentRollData = [NSKeyedArchiver archivedDataWithRootObject:_currentRoll];
                    NSUserDefaults *currentRoll = [NSUserDefaults standardUserDefaults];
                    [currentRoll setObject:currentRollData forKey:@"CurrentRoll"];
                    NSLog(@"set currentRoll with objectId = %@, and rollId = %@", _currentRoll.objectId, _currentRoll.rollId);
                    block(error);
                }];
            }];
        }];
    }
        return  _currentRoll;
}


//Attempt to fetch current roll out of NSUserDefaults
+ (Roll *)currentRoll {
    if (_currentRoll == nil) {
        PFQuery *getCurrentRoll = [User query];
        [getCurrentRoll includeKey:@"currentRoll"];
        [getCurrentRoll getObjectInBackgroundWithId:[User currentUser].objectId block:^(PFObject *object, NSError *error) {
            _currentRoll = [(User*)object currentRoll];
            NSData *currentRollData = [NSKeyedArchiver archivedDataWithRootObject:_currentRoll];
            NSUserDefaults *currentRoll = [NSUserDefaults standardUserDefaults];
            [currentRoll setObject:currentRollData forKey:@"CurrentRoll"];
            NSLog(@"set currentRoll with objectId = %@, and rollId = %@", _currentRoll.objectId, _currentRoll.rollId);
            NSLog(@"Fetching currentRoll with objectId = %@, and rollId = %@", _currentRoll.objectId, _currentRoll.rollId);
        }];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"CurrentRoll"];
    _currentRoll = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    NSLog(@"Fetching currentRoll with objectId = %@, and rollId = %@", _currentRoll.objectId, _currentRoll.rollId);
    return _currentRoll;
}

@end



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

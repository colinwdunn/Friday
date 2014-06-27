//
//  Roll.h
//  Friday
//
//  Created by Yousra Kamoona on 6/23/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Parse/Parse.h>

@interface Roll : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) NSString *rollName;
//@property PFFile *photosFile;
@property (nonatomic, strong) NSString *rollId;
@property int ownerId;

@property int maxPhotos;
@property int photosCount;

@end

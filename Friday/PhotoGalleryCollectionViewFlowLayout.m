//
//  PhotoGalleryCollectionViewFlowLayout.m
//  Friday
//
//  Created by Yousra Kamoona on 7/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PhotoGalleryCollectionViewFlowLayout.h"

@implementation PhotoGalleryCollectionViewFlowLayout

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(100, 100);
    self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    self.minimumInteritemSpacing = 2.0f;
    self.minimumLineSpacing = 2.0f;
    
    return self;
}

@end

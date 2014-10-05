//
//  SinglePhotoCollectionViewFlowLayout.m
//  Friday
//
//  Created by Yousra Kamoona on 10/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SinglePhotoCollectionViewFlowLayout.h"

@implementation SinglePhotoCollectionViewFlowLayout

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(320, 480);
    self.sectionInset = UIEdgeInsetsMake(2, 8, 2, 8);
    self.minimumInteritemSpacing = 2.0f;
    self.minimumLineSpacing = 2.0f;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setPagingEnabled:YES];
    
    return self;
}


@end

//
//  PhotoGalleryCell.h
//  Friday
//
//  Created by Yousra Kamoona on 6/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PhotoGalleryCell : UICollectionViewCell

- (void)setPhotoImage:(PFObject *)photo;

@end

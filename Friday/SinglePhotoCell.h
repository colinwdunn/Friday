//
//  SinglePhotoCell.h
//  Friday
//
//  Created by Yousra Kamoona on 10/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SinglePhotoCell : UICollectionViewCell

- (void)setPhotoImage:(PFObject *)photo;

@end

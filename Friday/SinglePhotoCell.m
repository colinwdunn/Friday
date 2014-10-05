//
//  SinglePhotoCell.m
//  Friday
//
//  Created by Yousra Kamoona on 10/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SinglePhotoCell.h"

@interface  SinglePhotoCell ()

@property (weak, nonatomic) IBOutlet PFImageView *singleImageView;
@end

@implementation SinglePhotoCell

- (void)setPhotoImage:(PFObject *)photos
{
    self.singleImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.singleImageView.backgroundColor = [UIColor yellowColor];
    self.singleImageView.file = [photos objectForKey:@"imageFile"];
    [self.singleImageView loadInBackground];
}
@end

//
//  PhotoGalleryCell.m
//  Friday
//
//  Created by Yousra Kamoona on 6/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PhotoGalleryCell.h"
#import <Parse/Parse.h>

@interface PhotoGalleryCell ()

@property (weak, nonatomic) IBOutlet PFImageView *photoImageView;
@end

@implementation PhotoGalleryCell

- (void)setPhotoImage:(PFObject *)photos {
    
    self.photoImageView.file = [photos objectForKey:@"imageFile"];
    [self.photoImageView loadInBackground];
}

@end

//
//  PhotoGalleryCell.m
//  Friday
//
//  Created by Yousra Kamoona on 6/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PhotoGalleryCell.h"

@interface PhotoGalleryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation PhotoGalleryCell

- (void)setPhotoImage:(UIImage *)photo{
    self.photoImageView.image = photo;
}

@end

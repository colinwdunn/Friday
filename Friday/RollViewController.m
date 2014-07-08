//
//  RollViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "RollViewController.h"
#import <Parse/Parse.h>
#import "PhotoGalleryCell.h"
#import "SplashViewController.h"

@interface RollViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *rollCollectionView;
@property (nonatomic, copy, readonly) NSString *photoGalleryCellClassName;
@property (weak, nonatomic) IBOutlet UIButton *startNewRollButton;

@end

@implementation RollViewController

- (NSString* )photoGalleryCellClassName {
    return NSStringFromClass([PhotoGalleryCell class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startNewRollButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.startNewRollButton.layer.borderWidth = 3;
    self.startNewRollButton.layer.cornerRadius = 20;
    
    [self setupCollectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoGalleryCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.photoGalleryCellClassName forIndexPath:indexPath];
    [photoCell setPhotoImage:self.photosArray[indexPath.item]];
    
    return photoCell;
}

- (void)setupCollectionView {
    UINib *nib = [UINib nibWithNibName:self.photoGalleryCellClassName bundle:nil];
    [self.rollCollectionView registerNib:nib forCellWithReuseIdentifier:self.photoGalleryCellClassName];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)createNewRoll:(id)sender {
    if (self.delegate !=nil) {
        [self.delegate didDismissRollViewController];
    }
    
}


@end

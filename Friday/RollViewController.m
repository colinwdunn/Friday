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
#import "CachedBlurredImage.h"
#import "RollGalleryLayoutViewController.h"
#import "CollectionViewHeaderView.h"

@interface RollViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *rollCollectionView;
@property (nonatomic, copy, readonly) NSString *photoGalleryCellClassName;
@property (weak, nonatomic) IBOutlet UIButton *startNewRollButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *fetchingRollIndicator;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *mainCollectionViewFlowLayout;
@property (strong, nonatomic) PFImageView *fullImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) NSTimer *rollTimer;

@end

@implementation RollViewController

- (NSString* )photoGalleryCellClassName {
    return NSStringFromClass([PhotoGalleryCell class]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startNewRollButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.startNewRollButton.layer.borderWidth = 3;
    self.startNewRollButton.layer.cornerRadius = 20;
    
    self.topView.layer.cornerRadius = 20;
    self.topView.alpha = .3;
    
    self.rollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(allPhotosDidUpload)
                                                    userInfo:nil
                                                     repeats:YES];
    
     self.imageView.image = [CachedBlurredImage getBlurredImage];
    
    [self setupCollectionView];
    
}

- (void)allPhotosDidUpload {
    [self.fetchingRollIndicator startAnimating];
        if ([Roll currentRoll].photosRemaining == 0) {
            [self.rollTimer invalidate];
            [self fetchRollPhotos];
        } else {
            [Roll getRollPhotosWithBlock:^(NSError *error, NSArray *photosArray) {
                if (photosArray.count == 6) {
                    [self.rollTimer invalidate];
                    [self fetchRollPhotos];
                    [Roll updatePhotoCountForCurrentRollWithBlock:^(NSError *error) {
                    
                    }];
                }
            }];
        }
}

- (void)fetchRollPhotos{
        [Roll getRollPhotosWithBlock:^(NSError *error, NSArray *photosArray) {
            [self.fetchingRollIndicator stopAnimating];
            self.photosArray = photosArray;
            [self.rollCollectionView reloadData];
    }];
}

- (void)setupCollectionView {
    UINib *nib = [UINib nibWithNibName:self.photoGalleryCellClassName bundle:nil];
    [self.rollCollectionView registerNib:nib forCellWithReuseIdentifier:self.photoGalleryCellClassName];
    
    [self.mainCollectionViewFlowLayout invalidateLayout];
    [self.rollCollectionView setCollectionViewLayout:self.mainCollectionViewFlowLayout animated:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else {
        return self.photosArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoGalleryCell *photoCell = (PhotoGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.photoGalleryCellClassName forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        UIButton *startNewRollButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 200, 43)];
        [startNewRollButton setTitle:@"Start a New Roll" forState:UIControlStateNormal] ;
        [startNewRollButton addTarget:self action:@selector(createNewRoll) forControlEvents:UIControlEventTouchUpInside];
        [startNewRollButton setTitleColor:[UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1] forState:UIControlStateNormal];
        [startNewRollButton setTitleColor:[UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1] forState:UIControlStateHighlighted];
        startNewRollButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
        startNewRollButton.layer.borderWidth = 3;
        startNewRollButton.layer.cornerRadius = 20;
        [photoCell.contentView addSubview:startNewRollButton];
        
    } else {
       [photoCell setPhotoImage:self.photosArray[indexPath.item]]; 
    }
    
    
    return photoCell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        [self createNewRoll];
//    } else {
//        RollGalleryLayoutViewController *rollGalleryLayoutVC = [[RollGalleryLayoutViewController alloc] initWithPhotoArray:self.photosArray];
//        [self presentViewController:rollGalleryLayoutVC animated:YES completion:nil];
//    }
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return CGSizeMake(400, 50);
    } else {
        return CGSizeMake(100, 100);
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 8, 2, 8);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0f;
}

- (void)createNewRoll {
    if (self.delegate !=nil) {
        [self.delegate didDismissRollViewController];
    }
}

- (IBAction)dimissRollViewController:(id)sender {
    if (self.delegate !=nil) {
        [self.delegate didDismissRollViewController2];
    }
}
@end

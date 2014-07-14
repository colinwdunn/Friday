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
#import "PhotoGalleryCollectionViewFlowLayout.h"

@interface RollViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *rollCollectionView;
@property (nonatomic, copy, readonly) NSString *photoGalleryCellClassName;
@property (weak, nonatomic) IBOutlet UIButton *startNewRollButton;

@property (strong, nonatomic) PhotoGalleryCollectionViewFlowLayout *mainCollectionViewFlowLayout;

@property (strong, nonatomic) PFImageView *fullImageView;

@property (weak, nonatomic) IBOutlet UIView *topView;
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
    [self setupCollectionView];
    self.topView.layer.cornerRadius = 20;
}

- (void)setupCollectionView {
    self.mainCollectionViewFlowLayout = [[PhotoGalleryCollectionViewFlowLayout alloc] init];
    self.rollCollectionView = [self.rollCollectionView initWithFrame:CGRectZero collectionViewLayout:self.mainCollectionViewFlowLayout];
    
    UINib *nib = [UINib nibWithNibName:self.photoGalleryCellClassName bundle:nil];
    [self.rollCollectionView registerNib:nib forCellWithReuseIdentifier:self.photoGalleryCellClassName];
    
    [self.mainCollectionViewFlowLayout invalidateLayout];
    [self.rollCollectionView setCollectionViewLayout:self.mainCollectionViewFlowLayout animated:YES];
    
    //setup collectioview header
    [self.rollCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionViewHeaderView"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoGalleryCell *photoCell = (PhotoGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.photoGalleryCellClassName forIndexPath:indexPath];
    [photoCell setPhotoImage:self.photosArray[indexPath.item]];
    
    return photoCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.fullImageView = [[PFImageView alloc] initWithFrame:self.view.frame];
    self.fullImageView.file = [self.photosArray[indexPath.item] objectForKey:@"imageFile"];
    self.fullImageView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.fullImageView];
    
    //for testing
    UIPanGestureRecognizer *panGestureRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissImage:)];
    [self.fullImageView addGestureRecognizer:panGestureRec];
}

- (void)dismissImage:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.fullImageView removeFromSuperview];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionViewHeaderView" forIndexPath:indexPath];
        
        if (reusableview == nil) {
            reusableview = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, self.rollCollectionView.frame.size.width, 50)];
        }
        
        return reusableview;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.rollCollectionView.frame.size.width, 50);
}

- (IBAction)createNewRoll:(id)sender {
    if (self.delegate !=nil) {
        [self.delegate didDismissRollViewController];
    }
}

- (void)setupGestureRecognizers {
    
}

@end

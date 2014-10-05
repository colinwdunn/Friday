//
//  RollGalleryLayoutViewController.m
//  Friday
//
//  Created by Yousra Kamoona on 9/19/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "RollGalleryLayoutViewController.h"
#import "SinglePhotoCollectionViewFlowLayout.h"
#import "SinglePhotoCell.h"

@interface RollGalleryLayoutViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) SinglePhotoCollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic, strong) NSArray *photoArray;

@end

@implementation RollGalleryLayoutViewController

- (NSString* )singlePhotoCellClassName {
    return NSStringFromClass([SinglePhotoCell class]);
}

- (id)initWithPhotoArray:(NSArray *)photoArray
{
    self = [super init];
    if (self) {
        self.photoArray = photoArray;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
}


- (void)setupCollectionView {
    self.collectionViewFlowLayout = [[SinglePhotoCollectionViewFlowLayout alloc] init];
    self.collectionView = [self.collectionView initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];

    UINib *nib = [UINib nibWithNibName:self.singlePhotoCellClassName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:self.singlePhotoCellClassName];
    
    [self.collectionViewFlowLayout invalidateLayout];
    [self.collectionView setCollectionViewLayout:self.collectionViewFlowLayout animated:YES];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SinglePhotoCell *photoCell = (SinglePhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.singlePhotoCellClassName forIndexPath:indexPath];
    [photoCell setPhotoImage:self.photoArray[indexPath.item]];
    
    return photoCell;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

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

@interface RollViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *rollCollectionView;
@property (nonatomic, copy, readonly) NSString *photoGalleryCellClassName;

@end

@implementation RollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (NSString* )photoGalleryCellClassName{
    return NSStringFromClass([PhotoGalleryCell class]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self loadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    PhotoGalleryCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.photoGalleryCellClassName forIndexPath:indexPath];
    [photoCell setPhotoImage:self.photosArray[indexPath.item]];
    
    return photoCell;
    
}

- (void)setupCollectionView {
    
    UINib *nib = [UINib nibWithNibName:self.photoGalleryCellClassName bundle:nil];
    [self.rollCollectionView registerNib:nib forCellWithReuseIdentifier:self.photoGalleryCellClassName];
}

- (void)loadData
{
    
}



@end

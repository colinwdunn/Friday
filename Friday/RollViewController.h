//
//  RollViewController.h
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RollViewControllerDelegate <NSObject>

- (void)didDismissRollViewController;

@end

@interface RollViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *photosArray;
@property (weak, nonatomic) id <RollViewControllerDelegate> delegate;

@end

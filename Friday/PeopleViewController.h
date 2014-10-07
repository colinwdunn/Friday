//
//  PeopleViewController.h
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPeopleViewController.h"

@protocol PeopleViewControllerDelegate;

@interface PeopleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddPeopleViewControllerDelegate>

@property (weak, nonatomic) id <PeopleViewControllerDelegate> delegate;

@end

@protocol PeopleViewControllerDelegate <NSObject>

- (void)didDismissPeopleViewController;

@end


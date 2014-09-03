//
//  AddPeopleViewController.h
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

<<<<<<< HEAD
@interface AddPeopleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate>
=======

@protocol AddPeopleViewControllerDelegate;

@interface AddPeopleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
>>>>>>> bbc67f0c941d70686d23184fc016d41830c72935

@property (weak, nonatomic) id <AddPeopleViewControllerDelegate> delegate;

@end

@protocol AddPeopleViewControllerDelegate <NSObject>

- (void)didDismissAddPeopleViewController;

@end

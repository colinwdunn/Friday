//
//  AddPeopleViewController.h
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@protocol AddPeopleViewControllerDelegate;

@interface AddPeopleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) id <AddPeopleViewControllerDelegate> delegate;

@end

@protocol AddPeopleViewControllerDelegate <NSObject>

- (void)didDismissAddPeopleViewController;

@end

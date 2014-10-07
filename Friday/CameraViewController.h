//
//  CameraViewController.h
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Roll.h"
#import "RollViewController.h"
#import "AddPeopleViewController.h"
#import "PeopleViewController.h"

@interface CameraViewController : UIViewController <RollViewControllerDelegate, AddPeopleViewControllerDelegate, PeopleViewControllerDelegate>

@end

//
//  PeopleViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PeopleViewController.h"
#import "AddPeopleViewController.h"


@interface PeopleViewController ()
@property (strong, nonatomic) IBOutlet UILabel *rollMemberListLabel;
@property (nonatomic) NSArray *groupMemberList;
- (IBAction)closeButtonDidPress:(id)sender;
- (IBAction)addContactDidPress:(id)sender;

@end

@implementation PeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMembersList:(NSArray *)groupMembers {
    self = [super self];
    if (self) {
        self.groupMemberList = groupMembers;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%@", self.groupMemberList);
}

- (IBAction)closeButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addContactDidPress:(id)sender {
    AddPeopleViewController *addPeopleVC = [[AddPeopleViewController alloc] init];
    [self presentViewController:addPeopleVC animated:YES completion:nil];
}
@end

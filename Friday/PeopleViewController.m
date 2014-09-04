//
//  PeopleViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PeopleViewController.h"
#import "AddPeopleViewController.h"
#import "CachedBlurredImage.h"
#import "Roll.h"


@interface PeopleViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSArray *groupMemberList;
@property (weak, nonatomic) IBOutlet UIButton *addPeopleButton;


//for demo
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedUserNameLabel;


- (IBAction)closeButtonDidPress:(id)sender;
- (IBAction)addContactDidPress:(id)sender;

@end

@implementation PeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.groupMemberList = [NSArray array];
    [Roll getMembersListInRollWithBlock:^(NSArray *membersArray, NSError *error) {
        self.groupMemberList = membersArray;
        self.ownerNameLabel.text = [User currentUser].username;
//        self.invitedUserNameLabel.text = [membersArray firstObject];
    }];
    self.imageView.image = [CachedBlurredImage getBlurredImage];
    
    self.addPeopleButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.addPeopleButton.layer.borderWidth = 3;
    self.addPeopleButton.layer.cornerRadius = 20;
}

- (IBAction)closeButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addContactDidPress:(id)sender {
    AddPeopleViewController *addPeopleVC = [[AddPeopleViewController alloc] init];
    [self presentViewController:addPeopleVC animated:YES completion:nil];
}
@end

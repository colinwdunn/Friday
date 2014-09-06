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
#import "GroupMemberCell.h"


@interface PeopleViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSArray *groupMemberList;
@property (weak, nonatomic) IBOutlet UIButton *addPeopleButton;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;


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
    [self.groupTableView registerNib:[UINib nibWithNibName:@"GroupMemberCell" bundle:nil] forCellReuseIdentifier:@"groupCell"];
    [Roll getMembersListInRollWithBlock:^(NSArray *membersArray, NSError *error) {
        self.groupMemberList = membersArray;
//      self.ownerNameLabel.text = [User currentUser].username;
//      self.invitedUserNameLabel.text = [membersArray firstObject];
        [self.groupTableView reloadData];
        //TODO: If group is empty state
    }];
    self.imageView.image = [CachedBlurredImage getBlurredImage];
    
    self.addPeopleButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.addPeopleButton.layer.borderWidth = 3;
    self.addPeopleButton.layer.cornerRadius = 20;
    [self.groupTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupMemberList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupMemberCell *cell = [self.groupTableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
    cell.memberName.text = self.groupMemberList[indexPath.row][@"invitedUserName"];
    cell.memberStatus.text = self.groupMemberList[indexPath.row][@"status"];
    
    return cell;
}

- (IBAction)closeButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addContactDidPress:(id)sender {
    AddPeopleViewController *addPeopleVC = [[AddPeopleViewController alloc] init];
    [self presentViewController:addPeopleVC animated:YES completion:nil];
}
@end

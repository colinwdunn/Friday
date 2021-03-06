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
#import <GPUImage/GPUImage.h>
#import "FridayCamera.h"


@interface PeopleViewController ()

@property (nonatomic) GPUImageVideoCamera *gpuImageVideoCamera;
@property (weak, nonatomic) IBOutlet UIView *blurCameraView;

@property (nonatomic) NSArray *groupMemberList;
@property (nonatomic) AddPeopleViewController *addPeopleVC;
@property (weak, nonatomic) IBOutlet UIButton *addPeopleButton;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) UIImage *image;

- (IBAction)closeButtonDidPress:(id)sender;
- (IBAction)addContactDidPress:(id)sender;

@end

@implementation PeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.groupMemberList = [NSArray array];
    [self.groupTableView registerNib:[UINib nibWithNibName:@"GroupMemberCell" bundle:nil] forCellReuseIdentifier:@"groupCell"];
    [self.groupTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [Roll getMembersListInRollWithBlock:^(NSArray *membersArray, NSError *error) {
        self.groupMemberList = membersArray;
        [self.groupTableView reloadData];
        //TODO: If group is empty state
    }];
    
    self.addPeopleButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.addPeopleButton.layer.borderWidth = 3;
    self.addPeopleButton.layer.cornerRadius = 20;
    [self.groupTableView reloadData];
    
    self.imageView.image = [CachedBlurredImage getBlurredImage];

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

- (void)didDismissAddPeopleViewController {
    [self.addPeopleVC dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeButtonDidPress:(id)sender {
    if (self.delegate != nil) {
        [self.delegate didDismissPeopleViewController];
    }
}

- (IBAction)addContactDidPress:(id)sender {
    self.addPeopleVC = [[AddPeopleViewController alloc] init];
    self.addPeopleVC.delegate = self;
    [self presentViewController:self.addPeopleVC animated:YES completion:nil];
}

@end

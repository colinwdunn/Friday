//
//  RollChoiceViewController.m
//  Friday
//
//  Created by Yousra Kamoona on 8/6/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "RollChoiceViewController.h"
#import "SplashViewController.h"
#import "CameraViewController.h"
#import "UserRoll.h"

//nico: 281-249-9718

@interface RollChoiceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *useInvitedToRollButton;
@property (weak, nonatomic) IBOutlet UIButton *startNewRollButton;
@property (weak, nonatomic) IBOutlet UIButton *continuExistingRollButton;
@property (weak, nonatomic) IBOutlet UITableView *invitedToRollsTableView;

@property (strong, nonatomic) NSArray *invitedToRollsArray;

- (IBAction)startNewRollButtonTapped:(id)sender;
- (IBAction)continuExistingRollButtonTapped:(id)sender;

@end

@implementation RollChoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpTableView];
    [self loadData];
}

- (void)loadData {
    [UserRoll getInvitedToRollsWithBlock:^(NSError *error, NSArray *invitedToRolls) {
        self.invitedToRollsArray = [NSArray arrayWithArray:invitedToRolls];
        [self.invitedToRollsTableView reloadData];
    }];
    
    if ([Roll currentRoll] == nil) {
        [Roll setCurrentRollFromParseWithBlock:^(NSError *error) {
            if ([Roll currentRoll] != nil) {
                if ([Roll currentRoll].photosCount <= 0) {
                    self.continuExistingRollButton.hidden = YES;
                }
            }
        }];
    }
}

- (void)setUpTableView {
    [self.invitedToRollsTableView registerNib:[UINib nibWithNibName:@"InvitedToCell" bundle:nil] forCellReuseIdentifier:@"InvitedToCell"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.invitedToRollsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitedToCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"InvitedToCell"];
    }
    cell.textLabel.text = [self.invitedToRollsArray[indexPath.row] rollName];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Roll setCurrentRoll:self.invitedToRollsArray[indexPath.row]];
    [User saveCurrentRoll:self.invitedToRollsArray[indexPath.row] toCurrentUserWithBlock:^(NSError *error) {
        [UserRoll updateRoll:self.invitedToRollsArray[indexPath.row] StatusToAcceptedWithBlock:^(NSError *error) {
            NSLog(@"Updated roll status");
            [self sendUserJoinedPushNotification];
            if ([User currentUser].isNew) {
                SplashViewController *splashVC = [[SplashViewController alloc] init];
                [self presentViewController:splashVC animated:YES completion:nil];
            } else {
                CameraViewController *cameraVC = [[CameraViewController alloc] init];
                [self presentViewController:cameraVC animated:YES completion:nil];
            }
            
        }];
    }];
}

- (void)sendUserJoinedPushNotification {
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@"has joined.", @"message", User.currentUser.username, @"name",  nil];
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:[Roll currentRoll].objectId];
    [push setData:data];
    [push sendPushInBackground];
    
}

- (IBAction)startNewRollButtonTapped:(id)sender {
    [Roll createRollWithBlock:^(NSError *error) {
        if ([User currentUser].isNew) {
            SplashViewController *splashVC = [[SplashViewController alloc] init];
            [self presentViewController:splashVC animated:YES completion:nil];
        } else {
            CameraViewController *cameraVC = [[CameraViewController alloc] init];
            [self presentViewController:cameraVC animated:YES completion:nil];
        }
    }];
}

- (IBAction)continuExistingRollButtonTapped:(id)sender {
    if ([User currentUser].isNew) {
        SplashViewController *splashVC = [[SplashViewController alloc] init];
        [self presentViewController:splashVC animated:YES completion:nil];
    } else {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        [self presentViewController:cameraVC animated:YES completion:nil];
    }
}
@end

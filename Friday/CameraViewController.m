//
//  CameraViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "CameraViewController.h"
#import "RollViewController.h"
#import "AddPeopleViewController.h"
#import "PeopleViewController.h"
#import "FridayCamera.h"
#import <Parse/Parse.h>
#import "Roll.h"
#import "Photo.h"
#import "NotificationsCustomView.h"

@interface CameraViewController ()

@property (nonatomic) FridayCamera *camera;
@property (nonatomic, assign) NSInteger photosCount;
@property (nonatomic, strong) NSArray *photoArrayOfPFObjects;
@property (nonatomic, strong) UIButton *showRollButton;
@property (nonatomic, assign) NSInteger currentCount;
@property (nonatomic, strong) NotificationsCustomView *notificationView;
@property (nonatomic, strong) IBOutlet UILabel *notificationsLabel;
@property (strong, nonatomic) IBOutlet UIButton *currentPhotoCountButton;
@property (weak, nonatomic) IBOutlet UILabel *tottalCountLable;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *numberOfMembersButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) RollViewController *rollVC;
@property (nonatomic, strong) AddPeopleViewController *addPeopleVC;
@property (nonatomic, assign) NSInteger numberOfMembers;

- (IBAction)takePhotoDidPress:(id)sender;
- (IBAction)addPeopleButtonDidPress:(id)sender;
- (IBAction)onShowMembersButtonPressed:(id)sender;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    NSLog(@"In the camera view");
    self.camera = [[FridayCamera alloc] init];
    [self.camera startRunningCameraSessionWithView:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNotificationView:) name:@"userJoined" object:nil];
    
    UINib *nib = [UINib nibWithNibName:@"NotificationsCustomView" bundle:nil];
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    
    self.notificationView = views[0];
    
    //styling top view
    self.topView.layer.cornerRadius = 20;
    
    //calculating number of roll members
    self.numberOfMembers = 1;
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentCount = [Roll currentRoll].photosRemaining;
    [self photoCountButtonControl];
    [self getMembersNumber];
}

- (void)getMembersNumber {
    [Roll getNumberOfMembersInRollWithBlock:^(NSInteger membersNumber, NSError *error) {
        self.numberOfMembers = membersNumber;
        self.numberOfMembersButton.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)self.numberOfMembers];
    }];
}

- (void)displayNotificationView:(NSNotification *)notification {
    self.notificationsLabel.text = [NSString stringWithFormat:@"%@", notification.userInfo[@"name"]];
    self.notificationView.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.notificationView.layer.backgroundColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.notificationView.layer.borderWidth = 3;
    self.notificationView.layer.cornerRadius = 20;
    self.notificationView.frame = CGRectMake(20, 70, 200, 50);

    [self.view addSubview:self.notificationView];
   
}

- (IBAction)takePhotoDidPress:(id)sender {
    [self updateCountSeamlessly];
    
    UIView *shutterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    shutterView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:shutterView];
    [UIView animateWithDuration:.5 animations:^{
        shutterView.alpha = 0;
    } completion:^(BOOL finished) {
        [shutterView removeFromSuperview];
    }];
    
    [self.camera photoOnCompletion:^(UIImage *takenPhoto, NSData *photoData) {
        [Photo createPhoto:takenPhoto];
    }];
}

- (void)updateCountSeamlessly {
    self.currentCount--;
    [self photoCountButtonControl];
}

- (void)photoCountButtonControl {
    if (self.currentCount <= 0) {
        self.currentPhotoCountButton.hidden = YES;
        self.showRollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.showRollButton.frame = CGRectMake(48, 500, 200, 43);
        self.showRollButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
        self.showRollButton.layer.borderWidth = 3;
        self.showRollButton.layer.cornerRadius = 20;
        self.showRollButton.layer.opaque = YES;
        [self.showRollButton setTitle: @"Show Roll" forState:UIControlStateNormal];
        self.showRollButton.titleLabel.textColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1];
        [self.showRollButton addTarget:self action:@selector(showRoll) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.showRollButton];
        self.takePhotoImageView.hidden = YES;
        self.tottalCountLable.hidden = YES;
    } else {
        self.showRollButton.hidden = YES;
        self.takePhotoImageView.hidden = NO;
        self.tottalCountLable.hidden = NO;
        self.currentPhotoCountButton.hidden= NO;
        [self.currentPhotoCountButton setTitle:[@(self.currentCount) stringValue] forState:UIControlStateNormal];
    }
}

- (void)showRoll {
    self.rollVC = [[RollViewController alloc] init];
    self.rollVC.delegate = self;
    [self presentViewController:self.rollVC animated:YES completion:nil];
}

- (void)didDismissRollViewController {
    [Roll createRollWithBlock:^(NSError *error) {
        self.currentCount = 6;
        self.currentPhotoCountButton.hidden = NO;
        self.takePhotoImageView.hidden = NO;
        self.tottalCountLable.hidden = NO;
        self.showRollButton.hidden = YES;
        [self photoCountButtonControl];
         [self.rollVC dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)addPeopleButtonDidPress:(id)sender {
    self.addPeopleVC = [[AddPeopleViewController alloc] init];
    self.addPeopleVC.delegate = self;
    [self presentViewController:self.addPeopleVC animated:YES completion:nil];
}

- (void)didDismissAddPeopleViewController {
    [self.addPeopleVC dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onShowMembersButtonPressed:(id)sender {
    PeopleViewController *peopleVC = [[PeopleViewController alloc] init];
    [self presentViewController:peopleVC animated:YES completion:nil];
}

@end

//Roll *newRoll = [Roll object];
//newRoll[@"user"] = [User currentUser];
//newRoll[@"photosCount"] = @(0);
//newRoll[@"maxPhotos"] = @(6);
//[newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//    PFObject *parseObjectRoll = [PFObject objectWithClassName:@"UserRolls"];
//    parseObjectRoll[@"user"] = [PFUser currentUser];
//    parseObjectRoll[@"roll"] = newRoll;
//    parseObjectRoll[@"status"] = @"accepted";
//    [parseObjectRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        // Roll *newRoll = [Roll currentRoll];
//        //[User currentUser].currentRoll = newRoll;
//        //self.roll = newRoll;
//        [self updatePhotoCountView];
//        //Hide show roll button
//        //Show photo count button
//         }];
//}];

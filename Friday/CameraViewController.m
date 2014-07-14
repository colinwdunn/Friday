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
#import "NotificationsCustomView.h"

@interface CameraViewController ()

@property (nonatomic) FridayCamera *camera;
@property (nonatomic, assign) NSInteger photosCount;
@property (nonatomic, strong) NSArray* photoArrayOfPFObjects;
@property (nonatomic, strong) RollViewController *rollVC;
@property (nonatomic, strong) UIButton *showRollButton;


@property (nonatomic, strong) NotificationsCustomView *notificationView;
@property (nonatomic, strong) IBOutlet UILabel *notificationsLabel;

- (IBAction)takePhotoDidPress:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *currentPhotoCountButton;
- (IBAction)addPeopleButtonDidPress:(id)sender;
- (IBAction)onShowMembersButtonPressed:(id)sender;

@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    NSLog(@"In the camera view");
    self.camera = [[FridayCamera alloc] init];
    [self.camera startRunningCameraSessionWithView:self];
    [self setCurrentRoll];
    self.currentPhotoCountButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNotificationView:) name:@"userJoined" object:nil];
    
    UINib *nib = [UINib nibWithNibName:@"NotificationsCustomView" bundle:nil];
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    
    self.notificationView = views[0];
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

- (void)setCurrentRoll {
    [[[Roll alloc] init] getCurrentRoll:[User currentUser] withSuccess:^(Roll *currentRoll) {
        self.roll = currentRoll;
        self.currentPhotoCountButton.hidden = NO;
        [self updatePhotoCount];
    } andFailure:^(NSError *error) {
        NSLog(@"Failed!!");
    }];
}

- (IBAction)takePhotoDidPress:(id)sender {
    UIView *shutterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    shutterView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:shutterView];
    [UIView animateWithDuration:.5 animations:^{
        shutterView.alpha = 0;
    } completion:^(BOOL finished) {
        [shutterView removeFromSuperview];
    }];
    
    [self.camera photoOnCompletion:^(UIImage *takenPhoto, NSData *photoData) {
        NSData *smallerImageData = UIImageJPEGRepresentation(takenPhoto, 0.5f);
        PFFile *imageFile = [PFFile fileWithData:smallerImageData];
        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
        photo[@"imageName"] = @"My trip to Hawaii!";
        photo[@"roll"] = self.roll;
        photo[@"imageFile"] = imageFile;
        
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self updatePhotoCount];
        }];
    }];
}

- (void)updatePhotoCount{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"roll" equalTo:self.roll];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.photosCount = 15 - objects.count;
        if (self.photosCount <= 0) {
            self.currentPhotoCountButton.hidden = YES;
            self.showRollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.showRollButton.frame = CGRectMake(120, 500, 100, 40);
            self.showRollButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
            self.showRollButton.layer.borderWidth = 3;
            self.showRollButton.layer.cornerRadius = 20;
            self.showRollButton.layer.opaque = YES;
            [self.showRollButton setTitle: @"Show Roll" forState:UIControlStateNormal];
            self.showRollButton.titleLabel.textColor = [UIColor yellowColor];
            [self.showRollButton addTarget:self action:@selector(showRoll) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.showRollButton];
        } else {
            self.showRollButton.hidden = YES;
            self.currentPhotoCountButton.hidden= NO;
            [self.currentPhotoCountButton setTitle:[@(self.photosCount) stringValue] forState:UIControlStateNormal];
        }
    }];
}

- (void)showRoll {
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"roll" equalTo:self.roll];
    __weak typeof(self) weakself = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakself.photoArrayOfPFObjects = [NSArray array];
            weakself.photoArrayOfPFObjects = objects;
            
            [weakself developRoll:weakself.photoArrayOfPFObjects];
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)developRoll: (NSArray*)photoArray {
    self.rollVC = [[RollViewController alloc] initWithNibName:@"RollViewController" bundle:nil];
    self.rollVC.delegate = self;
    self.rollVC.photosArray = self.photoArrayOfPFObjects;
    [self presentViewController:self.rollVC animated:YES completion:nil];
   
}

- (void)didDismissRollViewController {
    Roll *newRoll = [Roll object];
    newRoll[@"user"] = [User currentUser];
    [newRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFObject *parseObjectRoll = [PFObject objectWithClassName:@"UserRolls"];
        parseObjectRoll[@"user"] = [PFUser currentUser];
        parseObjectRoll[@"roll"] = newRoll;
        parseObjectRoll[@"status"] = @"accepted";
        [parseObjectRoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            self.roll = newRoll;
            [self updatePhotoCount];
            //Hide show roll button
            //Show photo count button
        }];
    }];
    [self.rollVC dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPeopleButtonDidPress:(id)sender {
    AddPeopleViewController *addPeopleVC = [[AddPeopleViewController alloc] init];
    [self presentViewController:addPeopleVC animated:YES completion:nil];
}

- (IBAction)onShowMembersButtonPressed:(id)sender {
    PeopleViewController *peopleVC = [[PeopleViewController alloc] init];
    [self presentViewController:peopleVC animated:YES completion:nil];
}

@end

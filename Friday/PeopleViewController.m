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

@property (nonatomic) FridayCamera *camera;
@property (nonatomic) GPUImageVideoCamera *gpuImageVideoCamera;
@property (weak, nonatomic) IBOutlet UIView *blurCameraView;

@property (nonatomic) NSArray *groupMemberList;
@property (nonatomic) AddPeopleViewController *addPeopleVC;
@property (weak, nonatomic) IBOutlet UIButton *addPeopleButton;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;

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

    self.camera = [[FridayCamera alloc] init];
    [self.camera initCameraSessionWithView:self];
    [self setupGPUImageBlurView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.camera startRunningCameraSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.camera stopRunningCameraSession];
}

- (void)setupGPUImageBlurView {
    self.gpuImageVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.gpuImageVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    blurFilter.blurRadiusInPixels = 40.0;
    [self disableAutoFocus];
    
    [self.blurCameraView addSubview:filteredVideoView];
    [self.gpuImageVideoCamera addTarget:blurFilter];
    [blurFilter addTarget:filteredVideoView];
    
    [self.gpuImageVideoCamera startCameraCapture];
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

- (void)disableAutoFocus {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device setFlashMode:AVCaptureFlashModeOff];
    
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error;
    for (AVCaptureDevice *device in devices) {
        if (([device hasMediaType:AVMediaTypeVideo]) &&
            ([device position] == AVCaptureDevicePositionBack) ) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                device.focusMode = AVCaptureFocusModeLocked;
                NSLog(@"Focus locked");
            }
            
            [device unlockForConfiguration];
        }
    }
}

- (IBAction)closeButtonDidPress:(id)sender {
    [self.camera stopRunningCameraSession];
    if (self.delegate != nil) {
        [self.delegate didDismissPeopleViewController];
    }
}

- (IBAction)addContactDidPress:(id)sender {
    self.addPeopleVC = [[AddPeopleViewController alloc] init];
    self.addPeopleVC.delegate = self;
    [self presentViewController:self.addPeopleVC animated:YES completion:nil];
}

- (void)didDismissAddPeopleViewController {
    [self.addPeopleVC dismissViewControllerAnimated:YES completion:nil];
}
@end

//
//  CameraViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "CameraViewController.h"
#import "FridayCamera.h"

@interface CameraViewController ()

@property (nonatomic) FridayCamera *camera;
- (IBAction)takePhotoDidPress:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *currentPhotoCountButton;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhotoDidPress:(id)sender {
    [self.camera photoOnCompletion:^(UIImage *takenPhoto, NSData *photoData) {
        PFFile *imageFile = [PFFile fileWithData:photoData];
        PFObject *photo = [PFObject objectWithClassName:@"photo"];
        photo[@"imageName"] = @"My trip to Hawaii!";
        photo[@"imageFile"] = imageFile;
        
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //[weakself downloadImages];
        }];
    }];
    int currentPhotoCount = [self.currentPhotoCountButton.titleLabel.text intValue];
    currentPhotoCount--;
    [self.currentPhotoCountButton setTitle:[@(currentPhotoCount) stringValue] forState:UIControlStateNormal];
}
@end

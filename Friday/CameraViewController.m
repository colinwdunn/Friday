//
//  CameraViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "CameraViewController.h"
#import "RollViewController.h"
#import "FridayCamera.h"
#import <Parse/Parse.h>

@interface CameraViewController ()

@property (nonatomic) FridayCamera *camera;
@property (nonatomic, assign) NSInteger photosCount;
@property (nonatomic, strong) NSArray* photoArrayOfPFObjects;

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
        self.photosCount = 4 - objects.count;
        if (self.photosCount == 0) {
            self.currentPhotoCountButton.hidden = YES;
            UIButton *showRollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            showRollButton.frame = CGRectMake(120, 500, 100, 40);
            showRollButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
            showRollButton.layer.borderWidth = 3;
            showRollButton.layer.cornerRadius = 20;
            showRollButton.layer.opaque = YES;
            [showRollButton setTitle: @"Show Roll" forState:UIControlStateNormal];
            showRollButton.titleLabel.textColor = [UIColor yellowColor];
            [showRollButton addTarget:self action:@selector(showRoll) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:showRollButton];
        
        } else {
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
    RollViewController *rollvc = [[RollViewController alloc] initWithNibName:@"RollViewController" bundle:nil];
    rollvc.photosArray = self.photoArrayOfPFObjects;
    [self presentViewController:rollvc animated:YES completion:nil];
   
}




@end

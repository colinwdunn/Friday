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
    
    [self updatePhotoCount];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhotoDidPress:(id)sender {
    
    [self.camera photoOnCompletion:^(UIImage *takenPhoto, NSData *photoData) {
        NSData *smallerImageData = UIImageJPEGRepresentation(takenPhoto, 0.5f);
        PFFile *imageFile = [PFFile fileWithData:smallerImageData];
        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
        photo[@"imageName"] = @"My trip to Hawaii!";
        photo[@"rollId"] = self.roll.rollId;
        photo[@"imageFile"] = imageFile;
        
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self updatePhotoCount];
        }];
    }];
}

- (void)updatePhotoCount{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"rollId" equalTo:self.roll.rollId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.photosCount = 6 - objects.count;
        if (self.photosCount == 0) {
            UIButton *showRollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            showRollButton.frame = CGRectMake(120, 200, 100, 40);
            showRollButton.titleLabel.text = @"Show Roll";
            showRollButton.backgroundColor = [UIColor redColor];
            [showRollButton addTarget:self action:@selector(showRoll) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:showRollButton];
        } else {
            [self.currentPhotoCountButton setTitle:[@(self.photosCount) stringValue] forState:UIControlStateNormal];
        }
    }];
}

- (void)showRoll {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"rollId" equalTo:self.roll.rollId];
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

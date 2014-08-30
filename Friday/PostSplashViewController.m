//
//  PostSplashViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PostSplashViewController.h"
#import "CameraViewController.h"
#import "AddPeopleViewController.h"
#import <Realm/Realm.h>
#import "CachedBlurredImage.h"

@interface PostSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *useContactsButton;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *processedImage;

@property (nonatomic, strong) AddPeopleViewController *addPeopleVC;

- (IBAction)contactsButtonDidPress:(id)sender;

@end

@implementation PostSplashViewController

- (id)initWithImage:(UIImage *)image processedImage:(UIImage *)processedImage {
    self = [super init];
    if (self) {
        self.image = image;
        self.processedImage = processedImage;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.useContactsButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.useContactsButton.layer.borderWidth = 3;
    self.useContactsButton.layer.cornerRadius = 20;
    
    self.imageView.image = self.processedImage;
}

- (IBAction)contactsButtonDidPress:(id)sender {
    self.addPeopleVC = [[AddPeopleViewController alloc] init];
    self.addPeopleVC.delegate = self;
    [self presentViewController:self.addPeopleVC animated:YES completion:nil];
}

- (void)didDismissAddPeopleViewController {
    [self.addPeopleVC dismissViewControllerAnimated:NO completion:^{
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        [self presentViewController:cameraVC animated:YES completion:nil];
    }];
}

@end

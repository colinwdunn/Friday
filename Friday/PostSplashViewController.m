//
//  PostSplashViewController.m
//  Friday
//
//  Created by Timothy Lee on 5/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "PostSplashViewController.h"

@interface PostSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *useContactsButton;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *processedImage;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.useContactsButton.layer.borderColor = [UIColor colorWithRed:251/255.0 green:211/255.0 blue:64/255.0 alpha:1].CGColor;
    self.useContactsButton.layer.borderWidth = 3;
    self.useContactsButton.layer.cornerRadius = 20;
    
//    self.imageView.image = self.processedImage;
    self.imageView.image = self.image;
}

//TODO: below code for testing. Remove when done.
- (IBAction)takeMorePhotos:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

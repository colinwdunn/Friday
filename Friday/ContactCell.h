//
//  ContactCell.h
//  Friday
//
//  Created by Joseph Anderson on 8/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contactTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *contactSelectedBackground;
@property (weak, nonatomic) IBOutlet UIImageView *contactCheckmark;

@end


//5403243885
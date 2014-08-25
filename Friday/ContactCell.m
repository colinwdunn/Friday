//
//  ContactCell.m
//  Friday
//
//  Created by Joseph Anderson on 8/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ContactCell.h"

@interface ContactCell ()


@end

@implementation ContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contactTitleLabelFrame = self.contactTitleLabel.frame;
}

@end

//
//  ELICollaborationTableViewCell.m
//  Learn
//
//  Created by Balázs Pete on 23/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELICollaborationTableViewCell.h"

@implementation ELICollaborationTableViewCell

@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

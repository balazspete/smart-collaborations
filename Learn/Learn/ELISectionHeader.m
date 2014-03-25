//
//  ELISectionHeader.m
//  Learn
//
//  Created by Balázs Pete on 18/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELISectionHeader.h"

@implementation ELISectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 500, 21)];
        self.label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f];
        [self.label setFont:[UIFont boldSystemFontOfSize:18]];
        
        [self addSubview:self.label];
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

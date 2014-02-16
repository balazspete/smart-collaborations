//
//  ELISidebar.m
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELISidebar.h"

@implementation ELISidebar

+ (int)sidebarWidth
{
    return 100;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (ELISidebar *)initWithinView:(UIView*)parentView
{
    return [self initWithinView:parentView considerNavidationItem:nil];
}

- (ELISidebar *)initWithinView:(UIView*)parentView considerNavidationItem:(UINavigationItem*)navigationItem
{
    return [self initWithFrame:[self getSizeWithinView:parentView considerNavigationItem:navigationItem]];
}

- (CGRect)getSizeWithinView:(UIView*)parentView considerNavigationItem:(UINavigationItem*)navigationItem
{
    int sidebarWidth = ELISidebar.sidebarWidth;
    CGSize collectionViewSize = parentView.bounds.size;
    CGRect sidebarSize =  parentView.bounds;
    
    if (navigationItem != nil)
    {
        int navigationHeight = navigationItem.titleView.bounds.size.height;
        sidebarSize = CGRectMake(collectionViewSize.width-navigationHeight-sidebarWidth, 0, sidebarWidth, collectionViewSize.height);
    }
    else
    {
        sidebarSize = CGRectMake(collectionViewSize.width-sidebarWidth, 0, sidebarWidth, collectionViewSize.height);
    }
    
    return sidebarSize;
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

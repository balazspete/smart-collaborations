//
//  ELISidebar.m
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELISidebar.h"

@interface ELISidebar ()

@property UIView *sidebar;
@property UIToolbar* backgroundToolbar;
@property UIView *overlay;

@end


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
    return [self initWithinView:parentView considerNavigationBar:nil];
}

- (ELISidebar *)initWithinView:(UIView*)parentView considerNavigationBar:(UINavigationBar*)navigationBar
{
    
    self = [self initWithFrame:parentView.bounds];
    
    int yOffset = navigationBar.bounds.size.height;
    
    _overlay = [[UIView alloc] initWithFrame:[self getOverlayBoundsWithinView:parentView]];
    _overlay.backgroundColor = [UIColor blackColor];
    [_overlay setAlpha:0.4f];
    [_overlay setHidden:YES];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnOverlay:)];
    [_overlay addGestureRecognizer:singleFingerTap];
    
    _sidebar = [[UIView alloc] initWithFrame:[self getToolbarSizeWithinView:parentView withVerticalOffset:yOffset]];
    _sidebar.backgroundColor = [UIColor clearColor];
    
    _backgroundToolbar = [[UIToolbar alloc] initWithFrame:_sidebar.frame];
    _backgroundToolbar.barStyle = UIBarStyleDefault;
    [_backgroundToolbar setTranslucent:YES];
    [_backgroundToolbar setHidden:YES];
    
    [parentView insertSubview:_overlay aboveSubview:parentView];
    [parentView insertSubview:_backgroundToolbar aboveSubview:_overlay];
    
    return self;
}

- (CGRect)getOverlayBoundsWithinView:(UIView*)parentView
{
    CGRect overlayBounds = parentView.frame;
    overlayBounds.size.width = overlayBounds.size.width - [ELISidebar sidebarWidth];
    return overlayBounds;
}

- (CGRect)getToolbarSizeWithinView:(UIView*)parentView withVerticalOffset:(int)yOffset
{
    int sidebarWidth = ELISidebar.sidebarWidth;
    CGSize collectionViewSize = parentView.bounds.size;
    CGRect sidebarSize =  parentView.bounds;
    
    sidebarSize = CGRectMake(collectionViewSize.width-sidebarWidth, 0, sidebarWidth, collectionViewSize.height);
    
    return sidebarSize;
}

- (void)readjustFrameWithinView:(UIView*)parentView considerNavigationBar:(UINavigationBar*)navigationBar
{
    [self setFrame:parentView.frame];
    [_backgroundToolbar setFrame:[self getToolbarSizeWithinView:parentView withVerticalOffset:navigationBar.bounds.size.height]];
    [_overlay setFrame:[self getOverlayBoundsWithinView:parentView]];
}


- (void)handleTapOnOverlay:(UITapGestureRecognizer *)recogniser
{
    [self hideSidebar];
}

- (void)showSidebar
{
    [_overlay setHidden:NO];
    [_backgroundToolbar setHidden:NO];
}

- (void)hideSidebar
{
    [_overlay setHidden:YES];
    [_backgroundToolbar setHidden:YES];
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

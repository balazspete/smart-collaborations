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
@property UITapGestureRecognizer *singleFingerTap;
@property BOOL sidebarAnimation;

@end


@implementation ELISidebar

+ (int)sidebarWidth
{
    return 100;
}

+ (float) getOverlayAlpha
{
    return 0.4f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _sidebarAnimation = YES;
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (ELISidebar *)initWithinController:(UIViewController*)controller
{
    
    self = [self initWithFrame:controller.view.frame];
    
    _overlay = [[UIView alloc] initWithFrame:[self getOverlayBoundsWithinController:controller]];
    _overlay.backgroundColor = [UIColor blackColor];
    [_overlay setAlpha:0];
    [_overlay setHidden:YES];
    
    _singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnOverlay:)];
    
    _sidebar = [[UIView alloc] initWithFrame:[self getToolbarSizeWithinController:controller]];
    _sidebar.backgroundColor = [UIColor clearColor];
    
    _backgroundToolbar = [[UIToolbar alloc] initWithFrame:_sidebar.frame];
    _backgroundToolbar.barStyle = UIBarStyleDefault;
    [_backgroundToolbar setTranslucent:YES];
    [_backgroundToolbar setHidden:YES];
    
    [controller.view insertSubview:_overlay aboveSubview:controller.view];
    [controller.view insertSubview:_backgroundToolbar aboveSubview:_overlay];
    
    return self;
}

- (CGRect)getOverlayBoundsWithinController:(UIViewController*)controller
{
    CGRect overlayBounds = controller.navigationController.view.frame;
    if (UIInterfaceOrientationIsLandscape(controller.interfaceOrientation))
    {
        float height = overlayBounds.size.height;
        overlayBounds.size.height = MIN(overlayBounds.size.height, overlayBounds.size.width);
        overlayBounds.size.width = MAX(height, overlayBounds.size.width);
    }
    
    overlayBounds.size.width = overlayBounds.size.width - [ELISidebar sidebarWidth];
    return overlayBounds;
}

- (CGRect)getToolbarSizeWithinController:(UIViewController*)controller
{
    int sidebarWidth = ELISidebar.sidebarWidth;
    
    CGSize viewSize = controller.navigationController.view.frame.size;
    if (UIInterfaceOrientationIsLandscape(controller.interfaceOrientation))
    {
        float height = viewSize.height;
        viewSize.height = MIN(viewSize.height, viewSize.width);
        viewSize.width = MAX(height, viewSize.width);
    }
    
    CGRect sidebarSize = CGRectMake(viewSize.width-sidebarWidth, 0, sidebarWidth, viewSize.height);
    return sidebarSize;
}

- (void)readjustFrameWithinController:(UIViewController*)controller
{
    CGRect toolbarSize = [self getToolbarSizeWithinController:controller];
    [_backgroundToolbar setFrame:toolbarSize];
    [_sidebar setFrame:toolbarSize];
    [_overlay setFrame:[self getOverlayBoundsWithinController:controller]];
}


- (void)handleTapOnOverlay:(UITapGestureRecognizer *)recogniser
{
    [self hideSidebar];
    [_overlay removeGestureRecognizer:_singleFingerTap];
}

- (void)showSidebar
{
    if (!_sidebarAnimation)
    {
        return;
    }
    _sidebarAnimation = NO;
    
    CGRect finalBounds = _backgroundToolbar.bounds;
    CGRect initialBounds = finalBounds;
    initialBounds.origin.x -= [ELISidebar sidebarWidth];
    [_backgroundToolbar setBounds:initialBounds];
    
    [_backgroundToolbar setHidden:NO];
    [_overlay setAlpha:0];

    float sidebarAnimation = 0.05;
    [UIView animateWithDuration:sidebarAnimation
            delay:0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                _backgroundToolbar.bounds = finalBounds;
            }
            completion:NULL];
    [UIView animateWithDuration:0.2
            delay:sidebarAnimation
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                [_overlay setHidden:NO];
                [_overlay setAlpha:[ELISidebar getOverlayAlpha]];
            }
            completion:^(BOOL finished){
                [_overlay addGestureRecognizer:_singleFingerTap];
            }];
}

- (void)hideSidebar
{
    _sidebarAnimation = YES;
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

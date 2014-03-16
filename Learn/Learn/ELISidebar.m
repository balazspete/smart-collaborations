//
//  ELISidebar.m
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELISidebar.h"
#import "ELIClassViewController.h"
#import "ELIAppDelegate.h"

@interface ELISidebar ()

@property UIToolbar* backgroundToolbar;
@property UIView *overlay;
@property UITapGestureRecognizer *singleFingerTap;
@property BOOL sidebarAnimation;

@end


@implementation ELISidebar

+ (int)sidebarWidth
{
    return 80;
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
    
    _backgroundToolbar = [[UIToolbar alloc] initWithFrame:[self getToolbarSizeWithinController:controller]];
    [_backgroundToolbar setTranslucent:YES];
    [_backgroundToolbar setHidden:YES];
    
    [controller.view insertSubview:_overlay atIndex:[controller.view.subviews count]];
    [controller.view insertSubview:_backgroundToolbar atIndex:[controller.view.subviews count]];
    
    int yOffset = 0;
    
    if ([controller class] == [ELIClassViewController class])
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, yOffset + 70, 50, 50)];
        yOffset += 70;
        
        [backButton setImage:[UIImage imageNamed:@"back-512.png"] forState:UIControlStateNormal];
        [backButton setTintColor:[UIColor blueColor]];
// Disable compiler warnings for this section, the selectors exist
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [backButton addTarget:controller action:@selector(goBackAPage) forControlEvents:UIControlEventTouchDown];
        [_backgroundToolbar addSubview:backButton];
    }
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(10, yOffset + 70, 60, 60)];
    yOffset += 70;
    
    [addButton setImage:[UIImage imageNamed:@"plus-512.png"] forState:UIControlStateNormal];
    [addButton setTintColor:[UIColor blueColor]];
    [addButton addTarget:controller action:@selector(sidebarAddEntry) forControlEvents:UIControlEventTouchDown];
    [_backgroundToolbar addSubview:addButton];
    
    if ([ELIAppDelegate device] && [controller class] == [ELIClassViewController class] && [ELIAppDelegate isLecturer]) {
        UIButton *takePicture = [[UIButton alloc] initWithFrame:CGRectMake(10, yOffset + 70, 60, 60)];
        [takePicture setImage:[UIImage imageNamed:@"old_time_camera-512.png"] forState:UIControlStateNormal];
        [takePicture setTintColor:[UIColor blueColor]];
        [takePicture addTarget:controller action:@selector(takePicture) forControlEvents:UIControlEventTouchDown];
        [_backgroundToolbar addSubview:takePicture];
    }
#pragma clang diagnostic pop
    
    [self readjustFrameWithinController:controller];
    
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

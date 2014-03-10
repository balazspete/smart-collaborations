//
//  ELISidebar.h
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELISidebar : UIView

+ (int) sidebarWidth;

+ (float) getOverlayAlpha;

- (ELISidebar *)initWithinController:(UIViewController*)controller;

- (void)readjustFrameWithinController:(UIViewController*)controller;

- (void)showSidebar;

- (void)hideSidebar;

- (void)handleTapOnOverlay:(UITapGestureRecognizer *)recogniser;

@end

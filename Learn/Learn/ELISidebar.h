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

- (ELISidebar *)initWithinView:(UIView*)parentView;

- (ELISidebar *)initWithinView:(UIView*)parentView considerNavigationBar:(UINavigationBar*)navigationBar;

- (void)readjustFrameWithinView:(UIView*)parentView considerNavigationBar:(UINavigationBar*)navigationBar;

- (void)showSidebar;

- (void)hideSidebar;

- (void)handleTapOnOverlay:(UITapGestureRecognizer *)recogniser;

@end

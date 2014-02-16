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

- (ELISidebar *)initWithinView:(UIView*)parentView;

- (ELISidebar *)initWithinView:(UIView*)parentView considerNavidationItem:(UINavigationItem*)navigationItem;

- (void)readjustFrameWithinView:(UIView*)parentView considerNavigationItem:(UINavigationItem*)navigationItem;

- (void)showSidebar;
- (void)hideSidebar;

- (void)handleTapOnOverlay:(UITapGestureRecognizer *)recogniser;

@end

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

@end

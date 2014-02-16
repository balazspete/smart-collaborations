//
//  ELIClassViewController.h
//  Learn
//
//  Created by Balázs Pete on 16/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELIClassViewController : UIViewController

- (void)showSidebar;
- (void)hideSidebar;

- (void)didRotate:(NSNotification*)notification;

@end

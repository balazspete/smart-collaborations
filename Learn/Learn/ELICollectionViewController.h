//
//  ELIColleactionViewController.h
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELICollectionViewController : UICollectionViewController

- (void)showSidebar;
- (void)hideSidebar;

- (void)didRotate:(NSNotification*)notification;

@end

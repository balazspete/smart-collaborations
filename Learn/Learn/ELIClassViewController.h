//
//  ELIClassViewController.h
//  Learn
//
//  Created by Balázs Pete on 16/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELILecture.h"

@interface ELIClassViewController : UIViewController

@property ELILecture *lecture;

@property (weak, nonatomic) IBOutlet UIProgressView *progressIndicator;

- (void)showSidebar;
- (void)hideSidebar;

- (void)didRotate:(NSNotification*)notification;

@property (weak, nonatomic) IBOutlet UIView *primary;
@property (weak, nonatomic) IBOutlet UIView *secondary;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

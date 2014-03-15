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
@property int currentPage;
@property bool showPageTitle;

@property (weak, nonatomic) IBOutlet UIProgressView *progressIndicator;

- (void)showSidebar;
- (void)hideSidebar;

- (void)didRotate:(NSNotification*)notification;

- (void)swapTitle;

- (void)createNewCollaborationEntry:(NSString*)text withImage:(UIImage*)image;

@property (weak, nonatomic) IBOutlet UIImageView *primary;
@property (weak, nonatomic) IBOutlet UIImageView *secondary;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

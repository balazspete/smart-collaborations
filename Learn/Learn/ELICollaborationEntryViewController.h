//
//  ELICollaborationEntryViewController.h
//  Learn
//
//  Created by Balázs Pete on 11/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELICollaborationEntry.h"

@interface ELICollaborationEntryViewController : UIViewController

@property ELICollaborationEntry *collaborationEntry;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UINavigationItem *modalNavigationBar;
@end

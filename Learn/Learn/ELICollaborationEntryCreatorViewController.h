//
//  ELICollaborationEntryCreatorViewController.h
//  Learn
//
//  Created by Balázs Pete on 11/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIkit/UIKit.h>

@interface ELICollaborationEntryCreatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end

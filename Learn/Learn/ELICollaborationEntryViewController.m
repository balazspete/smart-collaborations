//
//  ELICollaborationEntryViewController.m
//  Learn
//
//  Created by Balázs Pete on 11/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELICollaborationEntryViewController.h"

@interface ELICollaborationEntryViewController ()

@property UITapGestureRecognizer *overlayGestureRegogniser;

@end

@implementation ELICollaborationEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.modalNavigationBar.title = [NSString stringWithFormat:@"Collaboration Entry by %@", self.collaborationEntry.creator.name];
    self.userNameLabel.text = self.collaborationEntry.creator.name;
    
    if (self.collaborationEntry.text && self.collaborationEntry.text.length)
    {
        self.textView.text = self.collaborationEntry.text;
        self.textView.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithName:@"HelventicaNeue" size:20] size:20];
    }
    else
    {
        [self.textView setHidden:YES];
        
        CGRect frame = self.imageView.frame;
        frame.origin.y = self.imageView.frame.origin.y;
        [self.imageView setFrame:frame];
    }
    
    if (self.collaborationEntry.image)
    {
        self.imageView.image = [[UIImage alloc] initWithData:self.collaborationEntry.image];
    }
    else
    {
        [self.imageView setHidden:YES];
    }
    
    self.timeDateLabel.text = @"";
}

- (UITapGestureRecognizer*)createRecogniser:(SEL)selector
{
    UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [recogniser setNumberOfTapsRequired:1];
    recogniser.cancelsTouchesInView = NO;
    return recogniser;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.overlayGestureRegogniser = [self createRecogniser:@selector(handleTapBehind:)];
    [self.view.window addGestureRecognizer:self.overlayGestureRegogniser];
    [self.closeButton addGestureRecognizer:[self createRecogniser:@selector(closeModal:)]];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            [self.view.window removeGestureRecognizer:self.overlayGestureRegogniser];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)closeModal:(UITapGestureRecognizer *)sender
{
    [self.view.window removeGestureRecognizer:self.overlayGestureRegogniser];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

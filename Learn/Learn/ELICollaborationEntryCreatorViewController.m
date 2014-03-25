//
//  ELICollaborationEntryCreatorViewController.m
//  Learn
//
//  Created by Balázs Pete on 11/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELICollaborationEntryCreatorViewController.h"
#import "ELIAppDelegate.h"
#import "ELIClassViewController.h"

@interface ELICollaborationEntryCreatorViewController () < UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property ELIUser *user;
@property UITapGestureRecognizer *windowRecogniser;
@property UIImagePickerController *pickerController;
@property UIPopoverController *pickerPopoverController;
@property bool canDismiss;
@property bool textModified;

@property UIImage *selectedImage;

@end

@implementation ELICollaborationEntryCreatorViewController

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
    
    self.canDismiss = YES;
    self.textModified = NO;
    
    self.user = [ELIAppDelegate getUser];
    self.nameLabel.text = self.user.name;
    
    self.textView.text = @"Add some text if you would like to...";
    self.textView.textColor = [UIColor lightGrayColor];
    self.textView.delegate = self;
    
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.delegate = self;
    
    self.pickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.pickerController];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!self.textModified)
    {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
        self.textModified = YES;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (self.textView.text.length == 0)
    {
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.text = @"Add some text if you would like to...";
        [self.textView resignFirstResponder];
    }
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
    
    self.windowRecogniser = [self createRecogniser:@selector(handleOutsideTap:)];
    [self.view.window addGestureRecognizer:self.windowRecogniser];
    [self.cancelButton addGestureRecognizer:[self createRecogniser:@selector(handleCancelButton:)]];
    [self.doneButton addGestureRecognizer:[self createRecogniser:@selector(handleDoneButton:)]];
    [self.addImageButton addGestureRecognizer:[self createRecogniser:@selector(handleAddImageButton:)]];
}

- (void)handleOutsideTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil];
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            [self dismissModal];
        }
    }
}

- (void)handleCancelButton:(UITapGestureRecognizer *)sender
{
    [self dismissModal];
}

- (void)handleDoneButton:(UITapGestureRecognizer *)sender
{
    UINavigationController *nav = (UINavigationController*)self.presentingViewController;
    ELIClassViewController* classViewController = [nav.viewControllers lastObject];
    
    if (self.textModified && self.textView.text.length)
    {
        [classViewController createNewCollaborationEntry:self.textView.text withImage:self.selectedImage];
    }
    else
    {
        [classViewController createNewCollaborationEntry:nil withImage:self.selectedImage];
    }
    
    [self dismissModal];
}

- (void)handleAddImageButton:(UITapGestureRecognizer *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        self.canDismiss = NO;
        
        self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.pickerController.allowsEditing = YES;
        
        [self.pickerPopoverController presentPopoverFromRect:self.addImageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

- (void)dismissModal
{
    if (self.canDismiss || !self.pickerPopoverController.isPopoverVisible)
    {
        [self.view.window removeGestureRecognizer:self.windowRecogniser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // get image or something
    UIImage *result = [info objectForKey:UIImagePickerControllerEditedImage];
    self.selectedImage = result;
    self.previewImageView.image = result;
    
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.pickerPopoverController isPopoverVisible])
    {
        [self.pickerPopoverController dismissPopoverAnimated:YES];
    }
    self.canDismiss = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Do nothing?
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
}

@end

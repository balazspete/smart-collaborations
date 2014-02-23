//
//  ELIClassViewController.m
//  Learn
//
//  Created by Balázs Pete on 16/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIClassViewController.h"
#import "ELISidebar.h"
#import <RestKit/RestKit.h>
#import "ELICollaborationTableViewCell.h"

@interface ELIClassViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property ELISidebar *sidebar;

@end

@implementation ELIClassViewController

- (void)dismissAlertViewAndReturn:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showErrorType:(NSString*)typeDescription withMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:typeDescription message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
    [self performSelector:@selector(dismissAlertViewAndReturn:) withObject:alert afterDelay:3];
}

- (void)loadLecture
{
    RKObjectManager *objectmanager = [RKObjectManager sharedManager];
    [objectmanager getObjectsAtPath:_lecture.url parameters:nil
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        if ([mappingResult count] > 0)
        {
            _lecture = [[mappingResult array] objectAtIndex:0];
            self.progressIndicator.progress = 1.0f/[_lecture.pages count];
        }
        else
        {
            [self showErrorType:@"Empty lecture" withMessage:@"There haven't been any pages posted yet."];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showErrorType:@"Connection error" withMessage:error.localizedDescription];
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.view = self.tableView;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad	
{
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	// Do any additional setup after loading the view.
    
    [self navigationItem].title = _lecture.name;
    UIColor *backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1];
    self.view.backgroundColor = backgroundColor;
    self.tableView.backgroundColor = backgroundColor;
    self.primary.backgroundColor = backgroundColor;
    self.secondary.backgroundColor = backgroundColor;
    
    self.progressIndicator.progress = 0.0f;
    
    UIScreenEdgePanGestureRecognizer *swipeLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setEdges:UIRectEdgeRight];
    [swipeLeft setDelegate:self];
    [self.view addGestureRecognizer:swipeLeft];
    
    _sidebar = [[ELISidebar alloc] initWithinView:self.view considerNavigationBar:self.navigationController.navigationBar];
    
    [self loadLecture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleSwipeLeft:(id)sender
{
    [self showSidebar];
}

- (void)didRotate:(NSNotification*)notification
{
    // Resize when rotated
    [_sidebar readjustFrameWithinView:self.view considerNavigationBar:self.navigationController.navigationBar];
}

- (void)showSidebar
{
    [_sidebar readjustFrameWithinView:self.view considerNavigationBar:self.navigationController.navigationBar];
    [_sidebar showSidebar];
}

- (void)hideSidebar
{
    [_sidebar hideSidebar];
}

// Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELICollaborationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CollaborationTextCell"];
    cell.label.text = @"text";
    
    return cell;
}

@end

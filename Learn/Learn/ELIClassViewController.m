//
//  ELIClassViewController.m
//  Learn
//
//  Created by Balázs Pete on 16/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIClassViewController.h"
#import "ELISidebar.h"

@interface ELIClassViewController () <UIGestureRecognizerDelegate>

@property ELISidebar *sidebar;

@end

@implementation ELIClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    [self navigationItem].title = @"My Class";
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    
    UIScreenEdgePanGestureRecognizer *swipeLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setEdges:UIRectEdgeRight];
    [swipeLeft setDelegate:self];
    [self.view addGestureRecognizer:swipeLeft];
    
    NSLog(@"%f", self.navigationController.navigationBar.bounds.size.height);
    _sidebar = [[ELISidebar alloc] initWithinView:self.view considerNavigationBar:self.navigationController.navigationBar];
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

@end

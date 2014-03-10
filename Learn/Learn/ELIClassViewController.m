//
//  ELIClassViewController.m
//  Learn
//
//  Created by Balázs Pete on 16/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIAppDelegate.h"
#import "ELIClassViewController.h"
#import "ELISidebar.h"
#import <RestKit/RestKit.h>
#import "ELICollaborationTableViewCell.h"
#import "ELILecturePage.h"
#import "ELICollaborationEntry.h"

@interface ELIClassViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property ELISidebar *sidebar;
@property RKObjectManager *objectManager;
@property NSArray *collaborationEntries;
@property NSDateFormatter *dateFormat;
@property NSDateFormatter *timeFormat;

@end

@implementation ELIClassViewController

- (void)dismissAlertViewAndReturn:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showErrorType:(NSString*)typeDescription withMessage:(NSString*)message returnToClasses:(BOOL)returnToPrevious
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:typeDescription message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
    
    if (returnToPrevious) [self performSelector:@selector(dismissAlertViewAndReturn:) withObject:alert afterDelay:3];
}

- (void)loadImageWithURL:(NSURL*)imageURL intoImageView:(UIImageView*)imageView withAsynchronousDispatch:(bool)async
{
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    if (imageData)
    {
        UIImage *image = [UIImage imageWithData:imageData];
        if (image)
        {
            if (async)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                });
            }
            else
            {
                imageView.image = image;
            }
        }
    }
}

- (void)loadCollaborationWithURL:(NSString*)collaborationURL
{
    if (!collaborationURL)
    {
        return;
    }
    
    [_objectManager getObjectsAtPath:collaborationURL parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        
        _collaborationEntries = [NSArray arrayWithArray:mappingResult.array];
        [_tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
    }];
    
    
}

- (void)showPage:(NSNumber*)pageNumber
{
    if (pageNumber.floatValue == [self.lecture.pages count])
    {
        [self showErrorType:@"Last Page" withMessage:@"You are on the last page of the lecture." returnToClasses:NO];
        return;
    }
    
    self.progressIndicator.progress = (pageNumber.floatValue+1)/[self.lecture.pages count];
    
    ELILecturePage *page = [_lecture.pages objectAtIndex:pageNumber.integerValue];
    // Load Primary image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, page.primaryUrl]] intoImageView:self.primary withAsynchronousDispatch:YES];
    });
    // Load Secondary image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, page.secondaryUrl]] intoImageView:self.secondary withAsynchronousDispatch:YES];
    });
    // Load collaboration
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadCollaborationWithURL:page.collaborationUrl];
    });
}

- (void)loadLecture
{
    _objectManager = [RKObjectManager sharedManager];
    [_objectManager getObjectsAtPath:_lecture.url parameters:nil
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        if ([mappingResult count] > 0)
        {
            _lecture = [[mappingResult array] objectAtIndex:0];
            self.currentPage = 0;
            [self showPage:[NSNumber numberWithInt:self.currentPage]];
            [self swapTitle];
        }
        else
        {
            [self showErrorType:@"Empty lecture" withMessage:@"There haven't been any pages posted yet." returnToClasses:YES];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showErrorType:@"Connection error" withMessage:error.localizedDescription returnToClasses:YES];
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
    self.showPageTitle = NO;
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
    
    _sidebar = [[ELISidebar alloc] initWithinController:self];

    _timeFormat = [[NSDateFormatter alloc] init];
    [_timeFormat setDateFormat:@"HH:mm:ss"];
    _dateFormat = [[NSDateFormatter alloc] init];
    [_dateFormat setDateFormat:@"dd MMMM yyyy"];
    
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
    [_sidebar readjustFrameWithinController:self];
}

- (void)showSidebar
{
    [_sidebar readjustFrameWithinController:self];
    [_sidebar showSidebar];
}

- (void)hideSidebar
{
    [_sidebar hideSidebar];
}

- (void)swapTitle
{
    if (self.showPageTitle) {
        self.title = ((ELILecturePage*)[self.lecture.pages objectAtIndex:self.currentPage]).title;
    } else {
        self.title = self.lecture.name;
    }
    
    self.showPageTitle = !self.showPageTitle;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 15), dispatch_get_main_queue(), ^(void){
        [self swapTitle];
    });
}

// Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _collaborationEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELICollaborationEntry *entry = (ELICollaborationEntry*) [_collaborationEntries objectAtIndex:indexPath.row];
    
    bool text = entry.text != nil, image = entry.imageURL != nil;
    ELICollaborationTableViewCell *cell;
    
    if (text)
    {
        if (image)
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"CollaborationHybridCell"];
        }
        else
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"CollaborationTextCell"];
        }
        cell.textView.text = entry.text;
        [cell.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    }
    else
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"CollaborationImageCell"];
    }
    
    cell.userLabel.text = entry.creator.name;
    [cell.userLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]];
    [cell.userLabel sizeToFit];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"Posted at %@ on %@", [_timeFormat stringFromDate:entry.date], [_dateFormat stringFromDate:entry.date]];
    [cell.dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11]];
    [cell.dateLabel sizeToFit];
    
    if (image)
    {
        [self loadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, entry.imageURL]] intoImageView:cell.imageView withAsynchronousDispatch:NO];
        [cell.imageView setAutoresizingMask:UIViewAutoresizingNone];
        [cell.imageView setClipsToBounds:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected");
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((ELIClassViewController*)[segue destinationViewController]).lecture = self.lecture;
    return;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (sender == [self nextButton])
    {
        self.currentPage += 1;
        [self showPage:[NSNumber numberWithInt:self.currentPage]];
        return false;
    }
    
    return true;
}

@end

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
#import "ELICollaboration.h"
#import "ELICollaborationEntry.h"
#import "ELICollaborationEntryViewController.h"
#import <AFNetworking/AFNetworking.h>

#define LECTURE_REFRESH_RATE 1

@interface ELIClassViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property ELISidebar *sidebar;
@property RKObjectManager *objectManager;
@property NSMutableArray *collaborationEntries;
@property NSDateFormatter *dateFormat;
@property NSDateFormatter *timeFormat;

@property int pageSubmitted;

@property ELICollaborationEntry *selectedCollaborationEntry;

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

- (void)loadImageWithURL:(NSURL*)imageURL intoImageView:(UIImageView*)imageView withAsynchronousDispatch:(bool)async addToEntry:(ELICollaborationEntry*) entry
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
        
        if (entry)
        {
            entry.image = imageData;
        }
    }
}

- (void)loadCollaborationWithURL:(NSString*)collaborationURL allowFutureChecks:(bool)futureChecks
{
    if (((ELILecturePage*)[self.lecture.pages objectAtIndex:self.currentPage]).collaborationUrl != collaborationURL){
        return;
    }
    
    [self.objectManager getObjectsAtPath:collaborationURL parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        self.collaborationEntries = [NSMutableArray arrayWithArray:mappingResult.array];
        [self.tableView reloadData];
        
        if (futureChecks)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self loadCollaborationWithURL:collaborationURL allowFutureChecks:futureChecks];
                });
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
    }];
}

- (void)instructDisplay:(NSString*)imageURL
{
    if ([ELIAppDelegate device])
    {
        [self createTask:NO];
    }
}

- (void)showPage:(NSNumber*)pageNumber
{
    NSLog(@"Original: %d, Page: %f", self.currentPage, pageNumber.floatValue);
    if (pageNumber.floatValue < 0)
    {
        [self showErrorType:@"First Page" withMessage:@"You are on the first page of the lecture." returnToClasses:NO];
        return;
    }
    else if (pageNumber.floatValue >= [self.lecture.pages count])
    {
        [self showErrorType:@"Last Page" withMessage:@"You are on the last page of the lecture." returnToClasses:NO];
        return;
    }
    
    if (self.currentPage != pageNumber.integerValue)
    {
        self.collaborationEntries = [[NSMutableArray alloc] init];
        [self.tableView reloadData];
    }
    
    self.currentPage = pageNumber.intValue;
    self.progressIndicator.progress = (pageNumber.floatValue+1)/[self.lecture.pages count];
    
    ELILecturePage *page = [_lecture.pages objectAtIndex:pageNumber.integerValue];
    // Load Primary image
    if (page.primaryUrl.length)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, page.primaryUrl]] intoImageView:self.primary withAsynchronousDispatch:YES addToEntry:nil];
            
        });
    }
    // Load Secondary image
    if (page.secondaryUrl.length)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, page.secondaryUrl]] intoImageView:self.secondary withAsynchronousDispatch:YES addToEntry:nil];
        });
        if ([ELIAppDelegate isLecturer])
        {
            [self instructDisplay:page.secondaryUrl];
        }
    }
    // Load collaboration
    if (page.collaborationUrl.length)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadCollaborationWithURL:page.collaborationUrl allowFutureChecks:YES];
        });
    }
}

- (void)loadLecture
{
    _objectManager = [RKObjectManager sharedManager];
    [_objectManager getObjectsAtPath:_lecture.url parameters:nil
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        bool initial = self.lecture.pages.count;
        self.lecture = [[mappingResult array] objectAtIndex:0];
        if ([self.lecture.pages count] > 0)
        {
            if (!initial)
            {
                [self showPage:[NSNumber numberWithInt:0]];
                [self swapTitle];
            }
            else
            {
                self.progressIndicator.progress = ((float)self.currentPage+1)/self.lecture.pages.count;
                [self showPage:[NSNumber numberWithInt:self.currentPage]];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*LECTURE_REFRESH_RATE), dispatch_get_main_queue(), ^{
                NSLog(@"Refreshing lecture!");
                [self loadLecture];
            });
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
        self.pageSubmitted = -1;
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
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
    ELILecturePage *page = (ELILecturePage*)[self.lecture.pages objectAtIndex:self.currentPage];
    if (page && self.showPageTitle) {
        self.title = page.title;
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
    
    bool text = entry.text != nil, image = entry.imageURL != nil || entry.image != nil;
    ELICollaborationTableViewCell *cell;
    
    if (image)
    {
        if (text)
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"CollaborationHybridCell"];
            cell.textField.text = entry.text;
        }
        else
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"CollaborationImageCell"];
        }
        
        if (!entry.image)
        {
            [self loadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, entry.imageURL]] intoImageView:cell.imageView withAsynchronousDispatch:NO addToEntry:entry];
        }
        else
        {
            NSLog(@"HERE, loading from memory...");
            cell.imageView.image = [[UIImage alloc] initWithData:entry.image];
        }
        
        [cell.imageView setAutoresizingMask:UIViewAutoresizingNone];
        [cell.imageView setClipsToBounds:YES];
    }
    else
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"CollaborationTextCell"];
        cell.textField.text = entry.text;
    }
    
    
    cell.userLabel.text = entry.creator.name;
    [cell.userLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]];
    [cell.userLabel sizeToFit];
    
    if (entry.date)
    {
        cell.dateLabel.text = [NSString stringWithFormat:@"Posted at %@ on %@", [_timeFormat stringFromDate:entry.date], [_dateFormat stringFromDate:entry.date]];
    }
    else
    {
        cell.dateLabel.text = @"Uploading...";
    }
    [cell.dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11]];
    [cell.dateLabel sizeToFit];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    _selectedCollaborationEntry = [_collaborationEntries objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"CollaborationEntry" sender:tableView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELICollaborationEntry *entry = [_collaborationEntries objectAtIndex:indexPath.row];
    if (entry.imageURL)
    {
        if (entry.text && entry.text.length)
        {
            return 130;
        }
        return 100;
    }
    
    return 61;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender == [self nextButton])
    {
        ((ELIClassViewController*)[segue destinationViewController]).lecture = self.lecture;
        [self createTask:NO];
    }
    else if (sender == _tableView)
    {
        ((ELICollaborationEntryViewController*)[segue destinationViewController]).collaborationEntry = _selectedCollaborationEntry;
    }
    
    return;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (sender == [self nextButton])
    {
        [self showPage:[NSNumber numberWithInt:(self.currentPage+1)]];
        return false;
    }
    
    return true;
}

- (void)sidebarAddEntry
{
    [_sidebar hideSidebar];
    [self performSegueWithIdentifier:@"CreateCollaborationEntry" sender:_sidebar];
}

- (void)createNewCollaborationEntry:(NSString*)text withImage:(UIImage*)image
{
    ELICollaborationEntry *entry = [[ELICollaborationEntry alloc] init];
    [entry setText:text];
    
    ELIUser *user = [ELIAppDelegate getUser];
    [entry setCreator:user];
    
    [self.collaborationEntries addObject:entry];
    
    if (image)
    {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        [entry setImage:imageData];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self uploadCollaborationEntryImage:entry];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self proceedWithCollaborationEntryCreation:entry];
        });
    }
    
//    return;
    NSLog(@"HERE %lu", (unsigned long) self.collaborationEntries.count);
//    if (self.collaborationEntries.count < 1)
//    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[NSNumber numberWithLong:self.collaborationEntries.count-1].intValue inSection:[NSNumber numberWithInt:0].integerValue];
//        if (self.collaborationEntries.count < 2) {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        }
//    }
}

- (void)proceedWithCollaborationEntryCreation:(ELICollaborationEntry*)entry
{
    ELILecturePage *page = [self.lecture.pages objectAtIndex:self.currentPage];

//    if (!page.collaborationUrl || !page.collaborationUrl.length)
//    {
//        [self.objectManager postObject:nil path:@"/collaboration" parameters:@{} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//            ELICollaboration *collaboration = [mappingResult.array objectAtIndex:0];
//            if (!collaboration)
//            {
//                [self collaborationEntryCreationFailure];
//                return;
//            }
//            
//            NSLog(@"Created collaboration: %@", collaboration.url);
//            
//            
//            
//            ((ELILecturePage*)[self.lecture.pages objectAtIndex:self.currentPage]).collaborationUrl = collaboration.url;
//            [self completeCollaborationEntryCreation:entry collaborationURL:collaboration.url];
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            [self collaborationEntryCreationFailure];
//        }];
//        return;
//    }
    
    [self completeCollaborationEntryCreation:entry collaborationURL:page.collaborationUrl];
}

- (void)completeCollaborationEntryCreation:(ELICollaborationEntry*)entry collaborationURL:(NSString*)collaborationURL
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:entry.creator.url forKey:@"user"];
    
    if (entry.text)
    {
        [params setObject:entry.text forKey:@"body"];
    }
    
    if (entry.imageURL)
    {
        [params setObject:entry.imageURL forKey:@"image"];
    }
    
    [self.objectManager postObject:nil path:collaborationURL parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        ELICollaborationEntry *entry = [mappingResult.array firstObject];
        if (!entry)
        {
            [self collaborationEntryCreationFailure];
        }
        else
        {
            [self collaborationEntryCreationSuccess:entry];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self collaborationEntryCreationFailure];
    }];
    
}

- (void)collaborationEntryCreationSuccess:(ELICollaborationEntry*)entry
{
    unsigned long index = self.collaborationEntries.count-1;
    [self.collaborationEntries replaceObjectAtIndex:index withObject:entry];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[NSNumber numberWithLong:index].intValue inSection:[NSNumber numberWithInt:0].integerValue];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)collaborationEntryCreationFailure
{
    // show fail
    NSLog(@"We failed");
}

- (void)uploadCollaborationEntryImage:(ELICollaborationEntry*)entry
{
    NSLog(@"Starting upload...");
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"/image" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData){
        NSString *name = @"image";
        [formData appendPartWithFileData:entry.image name:name fileName:name mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"UPLOADED: %@", operation.responseString);
        [entry setImageURL:operation.responseString];
        
        [self proceedWithCollaborationEntryCreation:entry];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self collaborationEntryCreationFailure];
    }];
    
    [operation start];
}

- (void)goBackAPage
{
    [self showPage:[NSNumber numberWithInt:(self.currentPage-1)]];
    [self createTask:NO];
}

- (void)takePicture
{
    [self createTask:YES];
}

- (void)createTask:(bool)takePicture
{
    if (![ELIAppDelegate device] || ![ELIAppDelegate isLecturer])
    {
        return;
    }
    
    if (!takePicture)
    {
        if (self.pageSubmitted == self.currentPage+10) {
            NSLog(@"NOT CREATING TASK");
            return;
        }
        else
        {
            self.pageSubmitted = self.currentPage+10;
        }
    }
    
    ELILecturePage *page = [self.lecture.pages objectAtIndex:self.currentPage];
    NSString *path = [NSString stringWithFormat:@"%@/task", [ELIAppDelegate device].url];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[ELIAppDelegate device].url forKey:@"device"];
    [params setObject:page.secondaryUrl forKey:@"image"];
    [params setObject:(takePicture ? @"capture" : @"display") forKey:@"type"];
    
    [self.objectManager postObject:nil path:path parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"TAKEN");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR");
    }];
}

@end

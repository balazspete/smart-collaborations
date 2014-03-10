//
//  ELIColleactionViewController.m
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIAppDelegate.h"
#import "ELICollectionViewController.h"
#import "ELIClassViewController.h"
#import "ELILectureCell.h"
#import "ELISidebar.h"
#import "ELISectionHeader.h"
#import <RestKit/RestKit.h>
#import "ELIClass.h"
#import "ELILecture.h"

@interface ELICollectionViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property NSMutableArray* collectionData;
@property ELISidebar *sidebar;
@property UIActivityIndicatorView *indicator;

@end

@implementation ELICollectionViewController

- (void)loadClasses
{
    RKObjectManager *objectmanager = [RKObjectManager sharedManager];
    [objectmanager getObjectsAtPath:@"/classes" parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSArray *classes = [mappingResult array];
            _collectionData = classes.mutableCopy;
            [_indicator setHidden:YES];
            
            if (self.isViewLoaded)
            {
                [self.collectionView reloadData];
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:0, 1, nil]];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [_indicator setHidden:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
    }];
}

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
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.4f green:0.6f blue:0.8f alpha:0.5f];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    // TODO: set background colour
    
    [self.collectionView registerClass:[ELISectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeader"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"SectionFooter"];
    
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = self.title;
    
    UIScreenEdgePanGestureRecognizer *swipeLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setEdges:UIRectEdgeRight];
    [swipeLeft setDelegate:self];
    [self.view addGestureRecognizer:swipeLeft];
    
    _sidebar = [[ELISidebar alloc] initWithinController:self];

    if (self.collectionData != nil) {
        // Initialize to a blank one...
        self.collectionData = [NSMutableArray arrayWithObjects:nil];
    
        // Show a spinner
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGSize size = self.collectionView.frame.size;
        [_indicator setCenter:CGPointMake(size.width/2, size.height/2)];
        [self.collectionView addSubview:_indicator];
        [_indicator startAnimating];
    }
    
    
    
    [self loadClasses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ELIClass *class = [self.collectionData objectAtIndex:section];
    return [class.lectures count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.collectionData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELILectureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ELICell" forIndexPath:indexPath];
    ELIClass *class = [self.collectionData objectAtIndex:indexPath.section];
    ELILecture *lecture = [class.lectures objectAtIndex:indexPath.row];
    lecture.className = class.name;
    
    cell.label.text = lecture.name;
    cell.image.image = [UIImage imageNamed:@"small-icon.png"];
    cell.image.contentMode = UIViewContentModeScaleAspectFill;
    cell.image.bounds = CGRectMake(0, 0, 180, 180);
    cell.image.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1];
    
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.12f].CGColor;
    
    cell.lecture = lecture;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, lecture.imageUrl]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        if (imageData)
        {
            UIImage *image = [UIImage imageWithData:imageData];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.image.image = image;
                });
            }
        }
    });
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        ELIClass *class = [_collectionData objectAtIndex:indexPath.section];
        ELISectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SectionHeader" forIndexPath:indexPath];
        [header.label setText:[class.name uppercaseString]];
        header.label.textColor = [UIColor colorWithRed:0 green:0.8f blue:0 alpha:1];
        
        return header;
    }
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SectionFooter" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: select item
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(160, 190);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 0, 20);
}

// Two gestures may not be recognised simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (IBAction)handleSwipeLeft:(id)sender
{
    [self showSidebar];
}

- (IBAction)dismissController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didRotate:(NSNotification*)notification
{
    // Resize when rotated
    [_sidebar readjustFrameWithinController:self];
}

- (void)showSidebar
{
    [_sidebar showSidebar];
}

- (void)hideSidebar
{
    [_sidebar hideSidebar];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender class] != [ELILectureCell class]) return;
    if ([[segue destinationViewController] class] == [ELIClassViewController class])
    {
        ELILectureCell *cell = ((ELILectureCell*) sender);
        ((ELIClassViewController*)[segue destinationViewController]).lecture = cell.lecture;
    }
}

@end

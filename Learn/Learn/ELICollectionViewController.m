//
//  ELIColleactionViewController.m
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELICollectionViewController.h"
#import "ELICollectionCell.h"
#import "ELISidebar.h"

@interface ELICollectionViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property NSMutableArray* collectionData;
@property UIScreenEdgePanGestureRecognizer *swipeLeft;
@property ELISidebar *sidebar;
@property UIToolbar* backgroundToolbar;
@property UIView *overlay;

@end

@implementation ELICollectionViewController

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
    
    self.collectionData = [NSMutableArray arrayWithObjects:@"text1", @"text2", @"text3", @"text4", nil];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = self.title;
    
    _swipeLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [_swipeLeft setEdges:UIRectEdgeRight];
    [_swipeLeft setDelegate:self];
    [self.view addGestureRecognizer:_swipeLeft];
    
    _overlay = [[UIView alloc] initWithFrame:[self getOverlayBounds]];
    _overlay.backgroundColor = [UIColor blackColor];
    [_overlay setAlpha:0.7f];
    [_overlay setHidden:YES];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnOverlay:)];
    [_overlay addGestureRecognizer:singleFingerTap];
    
    _sidebar = [[ELISidebar alloc] initWithinView:self.collectionView considerNavidationItem:self.navigationItem];
    _sidebar.backgroundColor = [UIColor clearColor];
    
    _backgroundToolbar = [[UIToolbar alloc] initWithFrame:_sidebar.frame];
    _backgroundToolbar.barStyle = UIBarStyleDefault;
    [_backgroundToolbar setTranslucent:YES];
    [_backgroundToolbar setHidden:YES];
    
    [self.collectionView insertSubview:_overlay aboveSubview:self.collectionView];
    [self.collectionView insertSubview:_backgroundToolbar aboveSubview:_overlay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.collectionData count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELICollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ELICell" forIndexPath:indexPath];
    
    cell.label.text = [self.collectionData objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageNamed:@"small-icon.png"];
    cell.image.contentMode = UIViewContentModeScaleAspectFill;
    cell.image.bounds = CGRectMake(0, 0, 180, 180);
    
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.12f].CGColor;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];//[[UICollectionReusableView alloc] init];
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
    return CGSizeMake(200, 200);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
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

- (void)didRotate:(NSNotification*)notification
{
    // Resize when rotated
    [_overlay setFrame:[self getOverlayBounds]];
    [_backgroundToolbar setFrame:[_sidebar getSizeWithinView:self.collectionView considerNavigationItem:self.navigationItem]];
}

- (void)showSidebar
{
    [self.view removeGestureRecognizer:_swipeLeft];
    [_overlay setHidden:NO];
    [_backgroundToolbar setHidden:NO];
}

- (void)hideSidebar
{
    [self.view addGestureRecognizer:_swipeLeft];
    [_overlay setHidden:YES];
    [_backgroundToolbar setHidden:YES];
}

- (CGRect)getOverlayBounds
{
    CGRect overlayBounds = self.collectionView.frame;
    overlayBounds.size.width = overlayBounds.size.width - [ELISidebar sidebarWidth];
    return overlayBounds;
}

- (void)handleTapOnOverlay:(UITapGestureRecognizer *)recogniser
{
    [self hideSidebar];
}

@end

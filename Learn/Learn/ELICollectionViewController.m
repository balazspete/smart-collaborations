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
#import "ELISectionHeader.h"

@interface ELICollectionViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property NSMutableArray* collectionData;
@property ELISidebar *sidebar;

@end

@implementation ELICollectionViewController

- (void)loadClasses
{
    
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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.4f green:0.6f blue:0.8f alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [self.collectionView registerClass:[ELISectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeader"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"SectionFooter"];
    
    self.collectionData = [NSMutableArray arrayWithObjects:@"text1", @"text2", @"text3", @"text4", @"text3", @"text4", nil];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = self.title;
    
    UIScreenEdgePanGestureRecognizer *swipeLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setEdges:UIRectEdgeRight];
    [swipeLeft setDelegate:self];
    [self.view addGestureRecognizer:swipeLeft];
    
    _sidebar = [[ELISidebar alloc] initWithinView:self.collectionView considerNavigationBar:self.navigationController.navigationBar];
    
    [self loadClasses];
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
    return 2;
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
    if (kind == UICollectionElementKindSectionHeader) {
        ELISectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SectionHeader" forIndexPath:indexPath];
        [header.label setText:[@"Class name" uppercaseString]];
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

- (void)didRotate:(NSNotification*)notification
{
    // Resize when rotated]
    NSLog(@"%f %f %f",self.collectionView.backgroundView.frame.size.width, self.collectionView.frame.size.width, self.navigationController.navigationBar.frame.size.width);
    [_sidebar readjustFrameWithinView:self.collectionView considerNavigationBar:self.navigationController.navigationBar];
}

- (void)showSidebar
{
    [_sidebar showSidebar];
}

- (void)hideSidebar
{
    [_sidebar hideSidebar];
}

@end

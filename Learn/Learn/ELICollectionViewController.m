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
    
    // Register ELICollectionCell
    
    self.collectionData = [NSMutableArray arrayWithObjects:@"text1", @"text2", @"text3", @"text4", nil];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = self.title;
    
    _swipeLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [_swipeLeft setEdges:UIRectEdgeRight];
    [_swipeLeft setDelegate:self];
    [self.view addGestureRecognizer:_swipeLeft];
    
    
    _sidebar = [[ELISidebar alloc] initWithinView:self.collectionView considerNavidationItem:self.navigationItem];
    _sidebar.backgroundColor = [UIColor clearColor];
    
    _backgroundToolbar = [[UIToolbar alloc] initWithFrame:_sidebar.frame];
    _backgroundToolbar.barStyle = UIBarStyleDefault;
    [_backgroundToolbar setTranslucent:YES];
    [self.collectionView insertSubview:_backgroundToolbar aboveSubview:self.collectionView];
    [_backgroundToolbar setHidden:YES];
    
    //[self.collectionView ]
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
    [self.view removeGestureRecognizer:_swipeLeft];
    [_backgroundToolbar setHidden:NO];
    NSLog(@"HERE");
}

@end

//
//  ELIDevicesViewController.m
//  Learn
//
//  Created by Balázs Pete on 15/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIDevicesViewController.h"
#import <RestKit/RestKit.h>
#import "ELIDeviceCell.h"
#import "ELIDevice.h"
#import "ELIAppDelegate.h"

@interface ELIDevicesViewController () <UITableViewDelegate, UITableViewDataSource>

@property NSArray *devices;
@property NSIndexPath *current;

@end

@implementation ELIDevicesViewController

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
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    [manager getObjectsAtPath:@"/devices" parameters:@{} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (mappingResult.count) {
            self.devices = mappingResult.array;
            [self.tableView reloadData];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //code
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELIDeviceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    ELIDevice *device = [self.devices objectAtIndex:indexPath.row];
    
    cell.deviceName.text = @"Device";
    cell.deviceID.text = device.url;
    
    ELIDevice *current = [ELIAppDelegate device];
    if (current.url && current.url == device.url) {
        NSLog(@"%@ %@", current.url, device.url);
        cell.layer.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2f].CGColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ELIAppDelegate device:[self.devices objectAtIndex:indexPath.row]];

    NSArray *indices;
    if (self.current)
    {
        indices = @[self.current, indexPath];
    } else {
        indices = @[indexPath];
    }
    
    [self.tableView reloadRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationFade];
    self.current = indexPath;
}

@end

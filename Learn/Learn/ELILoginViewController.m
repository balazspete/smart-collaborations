//
//  ELILoginViewController.m
//  Learn
//
//  Created by Balázs Pete on 09/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELILoginViewController.h"
#import "ELIAppDelegate.h"
#import <RestKit/RestKit.h>

@interface ELILoginViewController ()

@end

@implementation ELILoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (sender == self.logInButton)
    {
        NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
        [lock lock];
        
        NSString *name = self.userNameField.text;
        [[RKObjectManager sharedManager] postObject:nil path:@"/user" parameters:@{@"name":name} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [ELIAppDelegate setUser:((ELIUser*)[mappingResult.array objectAtIndex:0])];
            [lock unlock];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            // show an alert...
        }];
        
        [lock lock];
        NSLog(@"%@", [ELIAppDelegate getUser].name);
        if (![ELIAppDelegate getUser])
        {
            return false;
        }
    }
    
    return true;
}

@end

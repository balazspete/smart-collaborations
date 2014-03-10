//
//  ELIAppDelegate.h
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELIUser.h"

#define BASEURL @"http://192.168.1.1"

@interface ELIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ELIUser*) getUser;
+ (void) setUser:(ELIUser*)user;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

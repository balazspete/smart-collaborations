//
//  ELIAppDelegate.m
//  Learn
//
//  Created by Balázs Pete on 15/02/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "ELIAppDelegate.h"
#import <RestKit/RestKit.h>
#import "ELICollectionViewController.h"
#import "ELIClass.h"
#import "ELILecture.h"
#import "ELILecturePage.h"
#import "ELICollaborationEntry.h"
#import "ELIUser.h"

static ELIUser* user;

@implementation ELIAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (ELIUser*) getUser
{
    return user;
}

+ (void) setUser:(ELIUser*)_user
{
    user = _user;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    // Let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialise HTTP client
    NSURL *baseUrl = [NSURL URLWithString:BASEURL];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    // Receive JSON responses
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    // Initialise RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // Describe pages
    RKObjectMapping *pagesMapping = [RKObjectMapping mappingForClass:[ELILecturePage class]];
    [pagesMapping addAttributeMappingsFromDictionary:@{
        @"url": @"url",
        @"title": @"title",
        @"primary": @"primaryUrl",
        @"secondary": @"secondaryUrl",
        @"collaboration": @"collaborationUrl"
    }];
    
    // Describe lectures
    RKObjectMapping *lectureMapping = [RKObjectMapping mappingForClass:[ELILecture class]];
    [lectureMapping addAttributeMappingsFromDictionary:@{
        @"url": @"url",
        @"name": @"name",
        @"image": @"imageUrl"
    }];
    RKRelationshipMapping *pagesToLectureRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"pages" toKeyPath:@"pages" withMapping:pagesMapping];
    [lectureMapping addPropertyMapping:pagesToLectureRelationshipMapping];
    
    // Describe classes
    RKObjectMapping *classMapping = [RKObjectMapping mappingForClass:[ELIClass class]];
    [classMapping addAttributeMappingsFromDictionary:@{
        @"url": @"url",
        @"name": @"name"
    }];
    
    // Describe relationship between classes and lectures
    RKRelationshipMapping *lectureToClassRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"lectures" toKeyPath:@"lectures" withMapping:lectureMapping];
    [classMapping addPropertyMapping:lectureToClassRelationshipMapping];
    
    // Register mappings with the provider using a response descriptor
    RKResponseDescriptor *classesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:classMapping method:RKRequestMethodGET pathPattern:@"/classes" keyPath:@"classes" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:classesResponseDescriptor];

    RKResponseDescriptor *lectureResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:lectureMapping method:RKRequestMethodGET pathPattern:@"/class/:classid/lecture/:lectureid" keyPath:@"lecture" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:lectureResponseDescriptor];
    
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[ELIUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
        @"url": @"url",
        @"name": @"name"
    }];
    
    RKObjectMapping *collaborationEntryMapping = [RKObjectMapping mappingForClass:[ELICollaborationEntry class]];
    [collaborationEntryMapping addAttributeMappingsFromDictionary:@{
        @"url": @"url",
        @"body": @"text",
        @"image": @"imageURL",
        @"time": @"date"
    }];
    
    RKRelationshipMapping *creatorToCollaborationEntryMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"creator" toKeyPath:@"creator" withMapping:userMapping];
    [collaborationEntryMapping addPropertyMapping:creatorToCollaborationEntryMapping];
    
    RKResponseDescriptor *collabrationResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:collaborationEntryMapping method:RKRequestMethodGET pathPattern:@"/collaboration/:id" keyPath:@"collaboration" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:collabrationResponseDescriptor];
    
    RKResponseDescriptor *createUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"/user" keyPath:@"user" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:createUserResponseDescriptor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Learn" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Learn.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

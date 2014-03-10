//
//  ELICollaborationEntry.h
//  Learn
//
//  Created by Balázs Pete on 09/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELIUser.h"

@interface ELICollaborationEntry : NSObject

@property NSString *url;
@property ELIUser *creator;
@property NSString *text;
@property NSString *imageURL;
@property NSDate *date;

@end

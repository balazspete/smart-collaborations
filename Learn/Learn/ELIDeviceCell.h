//
//  ELIDeviceCell.h
//  Learn
//
//  Created by Balázs Pete on 15/03/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELIDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *deviceID;

@end

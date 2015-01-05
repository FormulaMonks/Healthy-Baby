//
//  HBWeightViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/5/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBWeightViewController.h"
#import "Healthy_Baby-Swift.h"

@implementation HBWeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DeviceData *model = [[DeviceData alloc] init];
    
    [model fetchDevice:HBDeviceTypeWeight completionHandler:^(M2XDevice *device, NSArray *values, M2XResponse *response) {
        NSLog(@"%@", values);
    }];
}

@end

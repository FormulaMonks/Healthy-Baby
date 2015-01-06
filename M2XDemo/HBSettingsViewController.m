//
//  HBSettingsViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/6/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBSettingsViewController.h"
#import "Healthy_Baby-Swift.h"

@interface HBSettingsViewController ()
@property IBOutlet UINavigationBar *navBar;
@end

@implementation HBSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navBar.barTintColor = [Colors settingsColor];
    _navBar.tintColor = [UIColor whiteColor];
    _navBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    _navBar.barStyle = UIBarStyleBlack;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

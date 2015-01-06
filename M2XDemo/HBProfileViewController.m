//
//  HBProfileViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/6/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBProfileViewController.h"
#import "Healthy_Baby-Swift.h"

@interface HBProfileViewController ()
@property IBOutlet UINavigationBar *navBar;
@end

@implementation HBProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navBar.barTintColor = [Colors profileColor];
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

//
//  HBBaseViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/1/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBBaseViewController.h"

@interface HBBaseViewController ()

@end

@implementation HBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.barStyle = UIBarStyleBlack;
    bar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    bar.backgroundColor = [UIColor whiteColor];
    bar.translucent = NO;
    bar.tintColor = [UIColor whiteColor];
    
    UIImage *backBtn = [UIImage imageNamed:@"BackImage"];
    backBtn = [backBtn imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.navigationItem.backBarButtonItem.title=@"";
    self.navigationController.navigationBar.backIndicatorImage = backBtn;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backBtn;
}

+ (void)handleErrorAlert:(NSError *)error {
    NSString *message = error.localizedDescription;
    if (error.localizedFailureReason != nil) {
        message = [NSString stringWithFormat:@"%@: %@", message, error.localizedFailureReason];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end

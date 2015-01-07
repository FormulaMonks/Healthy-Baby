//
//  HBExerciseViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/6/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBExerciseViewController.h"
#import "Healthy_Baby-Swift.h"

@interface HBExerciseViewController () <ChartViewControllerDelegate>

@property IBOutlet UILabel *detailNoDataLabel;

@property ChartViewController *chartViewController;

@property M2XClient *client;
@property NSString *deviceId;

@end

@implementation HBExerciseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _client = [[M2XClient alloc] initWithApiKey:[defaults objectForKey:@"key"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *nav = self.navigationController.navigationBar;
    nav.barTintColor = [Colors exerciseColor];
    
    _chartViewController.color = [Colors exerciseColor];
    _detailNoDataLabel.alpha = 0;
    _detailNoDataLabel.textColor = [Colors grayColor];
    
    [ProgressHUD showCBBProgressWithStatus:@"Loading Device"];
    DeviceData *model = [[DeviceData alloc] init];
    [model fetchDevice:HBDeviceTypeExercise completionHandler:^(M2XDevice *device, NSArray *values, M2XResponse *response) {
        [ProgressHUD hideCBBProgress];
        
        if (response.error) {
            [HBBaseViewController handleErrorAlert:response.errorObject];
        } else {
            NSString *cache = response.headers[@"X-Cache"];
            if ([cache isEqualToString:@"HIT"]) {
                OLGhostAlertView *alert = [[OLGhostAlertView alloc] initWithTitle:@"Data from Cache" message:nil timeout:1.0 dismissible:YES];
                alert.style = OLGhostAlertViewStyleDark;
                [alert show];
                
                _chartViewController.cached = YES;
            }
            
            _deviceId = device[@"id"];
            _chartViewController.values = values;
            [self updateOnNewValuesAnimated];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ProgressHUD cancelCBBProgress];
}

- (void)updateOnNewValuesAnimated {
    [UIView animateWithDuration:1.0 animations:^{
        [self updateOnNewValues];
    }];
}

- (void)updateOnNewValues {
    _chartViewController.deviceIdLabel.text = @"ID: Apple Watch";
    
    [_chartViewController updateOnNewValues];
    
    _chartViewController.view.alpha = _chartViewController.maxIndex > 0 ? 1 : 0;
    _detailNoDataLabel.alpha = _chartViewController.maxIndex > 0 ? 0 : 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ChartViewController class]]) {
        _chartViewController = (ChartViewController *)segue.destinationViewController;
        _chartViewController.delegate = self;
        _chartViewController.axisXUnit = @"days";
        _chartViewController.axisYUnit = @"min";
    }
}

- (NSArray *)values {
    float value = [_chartViewController valueForIndex:0];
    NSString *today = [NSString stringWithFormat:@"%.2f %@", value, _chartViewController.axisYUnit];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    return @[
             [[ChartDetailValue alloc] initWithLabel:@"Goal" value:@"Mins Daily, Low Impact"],
             [[ChartDetailValue alloc] initWithLabel:@"Today" value:today],
             [[ChartDetailValue alloc] initWithLabel:@"Date" value:date],
             ];
}

@end

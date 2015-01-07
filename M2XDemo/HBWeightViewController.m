//
//  HBWeightViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/5/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBWeightViewController.h"
#import "Healthy_Baby-Swift.h"

@interface HBWeightViewController() <ChartViewControllerDelegate>

@property IBOutlet UILabel *detailNoDataLabel;

@property ChartViewController *chartViewController;

@property M2XClient *client;
@property NSString *deviceId;

@end

@implementation HBWeightViewController

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
    nav.barTintColor = [Colors weightColor];
    
    _chartViewController.color = [Colors weightColor];
    _detailNoDataLabel.alpha = 0;
    _detailNoDataLabel.textColor = [Colors grayColor];
    
    [ProgressHUD showCBBProgressWithStatus:@"Loading Device"];
    DeviceData *model = [[DeviceData alloc] init];
    [model fetchDevice:HBDeviceTypeWeight completionHandler:^(M2XDevice *device, NSArray *values, M2XResponse *response) {
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
    _chartViewController.deviceIdLabel.text = @"ID: Fitbit Scale";
    
    [_chartViewController updateOnNewValues];
    
    _chartViewController.view.alpha = _chartViewController.maxIndex > 0 ? 1 : 0;
    _detailNoDataLabel.alpha = _chartViewController.maxIndex > 0 ? 0 : 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ChartViewController class]]) {
        _chartViewController = (ChartViewController *)segue.destinationViewController;
        _chartViewController.delegate = self;
        _chartViewController.axisXUnit = @"weeks";
        _chartViewController.axisYUnit = @"lb";
    }
}

- (NSArray *)values {
    NSString *gain = @"-";
    
    if (_chartViewController.maxIndex > 0) {
        float min = [_chartViewController minValue];
        float max = [_chartViewController maxValue];
        float diff = max - min;
        gain = [NSString stringWithFormat:@"%.2f lb", diff];
    }
    
    return @[
             [[ChartDetailValue alloc] initWithLabel:@"Starting BMI 2" value:@"30"],
             [[ChartDetailValue alloc] initWithLabel:@"Goal" value:@"13-17 lbs"],
             [[ChartDetailValue alloc] initWithLabel:@"Baby Weight Gain" value:gain],
             ];
}

@end

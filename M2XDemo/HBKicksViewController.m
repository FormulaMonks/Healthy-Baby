//
//  HBKicksViewController.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/5/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "HBKicksViewController.h"
#import "Healthy_Baby-Swift.h"
#import <Parse/Parse.h>

@interface HBKicksViewController() <ChartViewControllerDelegate, AddKickViewControllerDelegate>

@property ChartViewController *chartViewController;

@property IBOutlet UIBarButtonItem *addButtonItem;
@property IBOutlet UIBarButtonItem *triggerButtonItem;

@property DeviceData *model;
@property M2XStream *stream;
@property M2XClient *client;
@property NSString *deviceId;

@property BOOL refreshKicks;

@end

@implementation HBKicksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _client = [[M2XClient alloc] initWithApiKey:[defaults objectForKey:@"key"]];
    _model = [[DeviceData alloc] init];

    UINavigationBar *nav = self.navigationController.navigationBar;
    nav.barTintColor = [Colors kickColor];
    
    [[self navigationItem] setRightBarButtonItems:@[_addButtonItem, _triggerButtonItem]];
    _addButtonItem.enabled = NO;
    _triggerButtonItem.enabled = NO;
    
    _chartViewController.color = [Colors kickColor];
    
    [self callWhenViewIsReady:^{
        
        if (![DeviceData isOffline]) {
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            CGPoint center = [_chartViewController.view convertPoint:_chartViewController.containerView.center toView:window];
            [ProgressHUD showCBBProgressWithStatus:@"Loading Device" center:center];
        }
        
        DeviceData *model = [[DeviceData alloc] init];
        [model fetchDevice:HBDeviceTypeKick completionHandler:^(M2XDevice *device, NSArray *values, M2XResponse *response) {
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
                
                _stream = [[M2XStream alloc] initWithClient:_client device:device attributes:@{@"name": HBStreamTypeKick}];
                _stream.client.delegate = _model; // for cache
                
                _deviceId = device[@"id"];
                _addButtonItem.enabled = YES;
                _triggerButtonItem.enabled = YES;
                
                if (values) {
                    _chartViewController.values = [self generateValuesForAllDays:values];
                }
                
                [self updateOnNewValuesAnimated];
                
                [self updateInstallation];
            }
        }];
        
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_refreshKicks) {
        [self loadData];
        _refreshKicks = NO;
    }
}

- (void)loadData {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGPoint center = [_chartViewController.view convertPoint:_chartViewController.containerView.center toView:window];
    [ProgressHUD showCBBProgressWithStatus:@"Loading Data" center:center];
   
    [_stream valuesWithParameters:@{@"limit": @1000} completionHandler:^(NSArray *objects, M2XResponse *response) {
        [ProgressHUD hideCBBProgress];
        
        NSString *cache = response.headers[@"X-Cache"];
        if ([cache isEqualToString:@"HIT"]) {
            OLGhostAlertView *alert = [[OLGhostAlertView alloc] initWithTitle:@"Data from Cache" message:nil timeout:1.0 dismissible:YES];
            alert.style = OLGhostAlertViewStyleDark;
            [alert show];
            
            _chartViewController.cached = YES;
        }
        
        if ([response error]) {
            [HBBaseViewController handleErrorAlert:response.errorObject];
        } else {
            _chartViewController.values = [self generateValuesForAllDays:[_model sortValues:objects]];
            [self updateOnNewValuesAnimated];
        }
    }];
}

- (NSArray *)generateValuesForAllDays:(NSArray *)values {
    if ([values count] == 0) {
        return values;
    }
    
    NSDictionary *first = values[[values count] - 1];
    NSString *firstTimestamp = first[@"timestamp"];
    NSDate *firstDate = [[NSDate fromISO8601:firstTimestamp] dateWithOutTime];
    NSDate *today = [[NSDate date] dateWithOutTime];
    
    int days = [today daysFrom:firstDate];
    
    NSMutableDictionary *byDates = [[NSMutableDictionary alloc] init];
    NSMutableArray *newValues = [[NSMutableArray alloc] init];
 
    for (NSDictionary *value in values) {
        NSString *timestamp = value[@"timestamp"];
        NSDate *date = [NSDate fromISO8601:timestamp];
        NSString *day = [date formattedDateWithFormat:@"LLL dd YYYY"];
        
        NSMutableArray *array = byDates[day];
        
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
            byDates[day] = array;
        }
        
        [array addObject:value];
    }
    
    if (byDates.count == 1) {
        return byDates.allValues[0];
    }
    
    for (int i = 0; i <= days; i++) {
        NSDate *date = [firstDate dateByAddingDays:i];
        NSString *day = [date formattedDateWithFormat:@"LLL dd YYYY"];
        
        NSMutableArray *array = byDates[day];
        if (array == nil) {
            [newValues addObject:@{@"timestamp": [date toISO8601], @"value": @0.0}];
        } else {
            float total = 0.0;
            for (NSDictionary *value in array) {
                total += [value[@"value"] floatValue];
            }
            
            float avg = total / [array count];
            
            [newValues addObject:@{@"timestamp": [date toISO8601], @"value": [NSNumber numberWithFloat:avg]}];
        }
    }
    
    return newValues.reverseObjectEnumerator.allObjects;
}

- (void)updateInstallation {
    if (_deviceId) {
        PFInstallation *install = [PFInstallation currentInstallation];
        [install setObject:_deviceId forKey:@"kicksDeviceId"];
        [install saveInBackground];
    }
}

- (void)updateOnNewValuesAnimated {
    [UIView animateWithDuration:1.0 animations:^{
        [self updateOnNewValues];
    }];
}

- (void)updateOnNewValues {
    _chartViewController.deviceIdLabel.text = @"ID: Healthy Baby App";
    
    [_chartViewController updateOnNewValues];
    
    _chartViewController.view.alpha = _chartViewController.maxIndex > 0 ? 1 : 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ChartViewController class]]) {
        _chartViewController = (ChartViewController *)segue.destinationViewController;
        _chartViewController.axisXUnit = @"intervals";
        _chartViewController.axisYUnit = @"kicks";
        _chartViewController.delegate = self;
    } else if ([segue.destinationViewController isKindOfClass:[PreKickViewController class]]) {
        PreKickViewController *pvc = (PreKickViewController *)segue.destinationViewController;
        pvc.deviceId = _deviceId;
        pvc.delegate = self;
    } else if ([segue.destinationViewController isKindOfClass:[TriggersViewController class]]) {
        TriggersViewController *pvc = (TriggersViewController *)segue.destinationViewController;
        pvc.deviceId = _deviceId;
    }
}

- (void)showTriggers:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Kick" bundle:nil];
    TriggersViewController *vc = [story instantiateViewControllerWithIdentifier:@"Triggers"];
    vc.deviceId = _deviceId;
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)startKicking:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Kick" bundle:nil];
    PreKickViewController *vc = [story instantiateViewControllerWithIdentifier:@"StartKicking"];
    vc.deviceId = _deviceId;
    vc.delegate = self;
    [[self navigationController] pushViewController:vc animated:YES];
}

- (NSArray *)values {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    return @[
             [[ChartDetailValue alloc] initWithLabel:@"Goal" value:@"10 kicks in 2 hours"],
             [[ChartDetailValue alloc] initWithLabel:@"Date" value:date],
             ];
}

- (NSString *)formatValue:(double)value {
    return [NSString stringWithFormat:@"%d", (int)value];
}

- (void)needsKicksRefresh {
    _refreshKicks = YES;
}

@end

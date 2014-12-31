//
//  NSDate+Time.m
//  M2XDemo
//
//  Created by Luis Floreani on 12/31/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "NSDate+Time.h"

@implementation NSDate (M2X)

- (NSDate *)dateWithOutTime {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end

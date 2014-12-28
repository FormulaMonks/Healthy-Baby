//
//  Helper.m
//  M2XDemo
//
//  Created by Luis Floreani on 12/19/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "Helper.h"
#import "NSDate+M2X.h"
#import "NSDate+DateTools.h"

@implementation Helper

+ (NSArray *)sortValues:(NSArray *)values {
    return [values sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [NSDate fromISO8601:obj1[@"timestamp"]];
        NSDate *date2 = [NSDate fromISO8601:obj2[@"timestamp"]];
        
        return [date1 isEarlierThan:date2];
    }];
}

@end

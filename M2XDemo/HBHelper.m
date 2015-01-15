//
//  Helper.m
//  M2XDemo
//
//  Created by Luis Floreani on 12/19/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import "HBHelper.h"
#import "NSDate+M2X.h"
#import "NSDate+DateTools.h"

static const float kDefaultBodySize = 17.0;

@implementation HBHelper

+ (NSArray *)sortValues:(NSArray *)values {
    return [values sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [NSDate fromISO8601:obj1[@"timestamp"]];
        NSDate *date2 = [NSDate fromISO8601:obj2[@"timestamp"]];
        
        if ([date1 isEarlierThan:date2]) {
            return NSOrderedDescending;
        } else if ([date2 isEarlierThan:date1]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

+ (void)configureDynamicTypeFor:(id)control keypath:(NSString *)keypath {
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    float userSize = [userFont pointSize];
    float scale = userSize / kDefaultBodySize;
    UIFont *font = (UIFont *)[control valueForKeyPath:keypath];
    UIFont *newFont;
    if ([font.fontName containsString:@"Bold"]) {
        newFont = [UIFont fontWithName:@"ProximaNova-Bold" size:[font pointSize] * scale];
    } else {
        newFont = [UIFont fontWithName:@"Proxima Nova" size:[font pointSize] * scale];
    }
    
    [control setValue:newFont forKeyPath:keypath];
}

@end

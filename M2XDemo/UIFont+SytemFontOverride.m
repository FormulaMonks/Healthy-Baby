//
//  UIFont+SytemFontOverride.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/1/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "UIFont+SytemFontOverride.h"

@implementation UIFont (SytemFontOverride)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"ProximaNova-Bold" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Proxima Nova" size:fontSize];
}

#pragma clang diagnostic pop

@end

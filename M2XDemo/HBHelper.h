//
//  Helper.h
//  M2XDemo
//
//  Created by Luis Floreani on 12/19/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const CGFloat kDefaultBodySize;

@interface HBHelper : NSObject

// since sorting in swift is horrendous slow...
+ (NSArray *)sortValues:(NSArray *)values;

+ (void)configureDynamicTypeFor:(id)control keypath:(NSString *)keypath;

@end

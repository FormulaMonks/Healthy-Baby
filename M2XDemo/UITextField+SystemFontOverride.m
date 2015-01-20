//
//  UITextField+SystemFontOverride.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/15/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "UITextField+SystemFontOverride.h"
#import "HBHelper.h"

@implementation UITextField (SystemFontOverride)

-(void)awakeFromNib{
    [HBHelper configureDynamicTypeFor:self keypath:@"font"];
}

@end

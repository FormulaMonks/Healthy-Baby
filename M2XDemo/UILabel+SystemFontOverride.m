//
//  UILabel+SystemFontOverride.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/1/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "UILabel+SystemFontOverride.h"
#import "HBHelper.h"

@implementation UILabel (SystemFontOverride)

-(void)awakeFromNib{
    [HBHelper configureDynamicTypeFor:self keypath:@"font"];
}

@end

//
//  UIButton+SystemFontOverride.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/15/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "UIButton+SystemFontOverride.h"
#import "HBHelper.h"

@implementation UIButton (SystemFontOverride)

-(void)awakeFromNib{
    [HBHelper configureDynamicTypeFor:self keypath:@"titleLabel.font"];

}

@end

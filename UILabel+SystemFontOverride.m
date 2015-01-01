//
//  UILabel+SystemFontOverride.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/1/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "UILabel+SystemFontOverride.h"

@implementation UILabel (SystemFontOverride)

-(void)awakeFromNib{
    float fontSize = [self.font pointSize];
    if ([self.font.fontName containsString:@"Bold"]) {
        self.font = [UIFont fontWithName:@"ProximaNova-Bold" size:fontSize];
    } else {
        self.font = [UIFont fontWithName:@"Proxima Nova" size:fontSize];
    }
}

@end

//
//  UILabel+SystemFontOverride.m
//  M2XDemo
//
//  Created by Luis Floreani on 1/1/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

#import "UILabel+SystemFontOverride.h"

static const float kDefaultBodySize = 17.0;

@implementation UILabel (SystemFontOverride)

-(void)awakeFromNib{
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    float userSize = [userFont pointSize];
    float scale = userSize / kDefaultBodySize;
    if ([self.font.fontName containsString:@"Bold"]) {
        self.font = [UIFont fontWithName:@"ProximaNova-Bold" size:[self.font pointSize] * scale];
    } else {
        self.font = [UIFont fontWithName:@"Proxima Nova" size:[self.font pointSize] * scale];
    }
}

@end

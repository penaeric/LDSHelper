//
//  UIColor+LDSColors.m
//  LDSHelper
//
//  Created by Eric Pena on 10/1/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "UIColor+LDSColors.h"

@implementation UIColor (LDSColors)

+ (UIColor *)LDSBlueColor
{
    static UIColor *LDSBlue = nil;
    
    if (!LDSBlue) {
        LDSBlue = [UIColor colorWithRed:0/255.0 green:70/255.0 blue:138/255.0 alpha:1];
    }
    
    return LDSBlue;
}


+ (UIColor *)LDSBlueMenuSelectedColor
{
    static UIColor *LDSBlueMenuSelected = nil;
    
    if (!LDSBlueMenuSelected) {
        LDSBlueMenuSelected = [UIColor colorWithRed:27/255. green:12/255. blue:229/255. alpha:1.];
    }
    
    return LDSBlueMenuSelected;
}


+ (UIColor *)LDSDarkGrayColor
{
    static UIColor *LDSDarkGray = nil;
    
    if (!LDSDarkGray) {
        LDSDarkGray = [UIColor darkGrayColor];
    }
    
    return LDSDarkGray;
}


+ (UIColor *)LDSGreenColor
{
    static UIColor *LDSGreenColor = nil;
    
    if (!LDSGreenColor) {
        LDSGreenColor = [UIColor colorWithRed:119/255.0 green:187/255.0 blue:103/255.0 alpha:1];
    }
    
    return LDSGreenColor;
}


+ (UIColor *)LDSLightGrayColor
{
    static UIColor *LDSLightGray = nil;
    
    if (!LDSLightGray) {
        LDSLightGray = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    }
    
    return LDSLightGray;
}


+ (UIColor *)LDSMediumGrayColor
{
    return [UIColor grayColor];
}


+ (UIColor *)LDSOrangeColor
{
    static UIColor *LDSOrange = nil;
    
    if (!LDSOrange) {
        LDSOrange = [UIColor colorWithRed:203/255.0 green:162/255.0 blue:112/255.0 alpha:1];
    }
    
    return LDSOrange;
}


+ (UIColor *)LDSRedColor
{
    static UIColor *LDSRed = nil;
    
    if (!LDSRed) {
        LDSRed = [UIColor colorWithRed:198/255.0 green:109/255.0 blue:117/255.0 alpha:1];
    }
    
    return LDSRed;
}

@end

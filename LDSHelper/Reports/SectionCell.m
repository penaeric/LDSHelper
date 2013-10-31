//
//  SectionCell.m
//  LDSHelper
//
//  Created by Eric Pena on 8/24/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "SectionCell.h"

@implementation SectionCell

- (void)awakeFromNib
{
    UIImage *gradientImage = [UIImage imageNamed:@"gradient.png"];
    self.numberLabel.textColor = [UIColor colorWithPatternImage:gradientImage];
}

@end

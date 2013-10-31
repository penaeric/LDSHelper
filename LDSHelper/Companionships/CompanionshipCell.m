//
//  CompanionshipCell.m
//  LDSHelper
//
//  Created by Eric Pena on 9/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "CompanionshipCell.h"

@implementation CompanionshipCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.thumbnailImageLeft.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.thumbnailImageRight.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.thumbnailImageLeft.layer.borderWidth = 1.5;
    self.thumbnailImageRight.layer.borderWidth = 1.5;
    self.thumbnailImageLeft.layer.cornerRadius = 5;
    self.thumbnailImageRight.layer.cornerRadius = 5;
}

@end

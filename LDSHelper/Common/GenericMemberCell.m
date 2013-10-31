//
//  GenericMemberCell.m
//  LDSHelper
//
//  Created by Eric Pena on 9/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "GenericMemberCell.h"

@implementation GenericMemberCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.thumbnailImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.thumbnailImage.layer.borderWidth = 1.5;
    self.thumbnailImage.layer.cornerRadius = 5;
}

@end

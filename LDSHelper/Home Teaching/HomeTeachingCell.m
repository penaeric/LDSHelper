//
//  HomeTeachingCell.m
//  LDSHelper
//
//  Created by Eric Pena on 9/23/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "HomeTeachingCell.h"

@implementation HomeTeachingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Visit labels
    self.visitLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.visitedLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.visitLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.visitedLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.visitLabel.layer.borderWidth = 0.5;
    self.visitedLabel.layer.borderWidth = 0.5;
    self.visitLabel.layer.cornerRadius = 5;
    self.visitedLabel.layer.cornerRadius = 5;
    
    // Thumbnail Images
    self.thumbnailImageLeft.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.thumbnailImageRight.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.thumbnailImageLeft.layer.borderWidth = 1.5;
    self.thumbnailImageRight.layer.borderWidth = 1.5;
    self.thumbnailImageLeft.layer.cornerRadius = 5;
    self.thumbnailImageRight.layer.cornerRadius = 5;
}

@end

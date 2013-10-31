//
//  Person+AddOns.h
//  LDSHelper
//
//  Created by Eric Pena on 6/25/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Person.h"

@interface Person (AddOn)

- (NSString *)fullName;
- (NSString *)cityStateZipAddress;
- (void)setThumbnailDataFromImage:(UIImage *)image;
- (void)setThumbnailSmallDataFromImage:(UIImage *)image;

@end

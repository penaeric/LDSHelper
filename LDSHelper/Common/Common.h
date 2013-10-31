//
//  Common.h
//  LDSHelper
//
//  Created by Eric Pena on 6/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Organization.h"

@interface Common : NSObject

+ (NSData *)thumbnailDataForImage:(UIImage *)image width:(CGFloat)width heigth:(CGFloat)height cornerRadius:(CGFloat)radius;
+ (UIImage *)grayImageForImage:(UIImage *)image;
+ (NSString *)normalizedString:(NSString *)string;

@end

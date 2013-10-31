//
//  Common.m
//  LDSHelper
//
//  Created by Eric Pena on 6/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@import QuartzCore;
#import "Common.h"

@implementation Common

+ (NSData *)thumbnailDataForImage:(UIImage *)image width:(CGFloat)width heigth:(CGFloat)height cornerRadius:(CGFloat)radius
{
    if (!image) {
        return nil;
    }
    
    CGSize origImageSize = [image size];
    
    CGRect newRect = CGRectMake(0, 0, width, height);
    
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:radius];
    
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *data = UIImagePNGRepresentation(smallImage);
    
    UIGraphicsEndImageContext();
    
    return data;
}


// TODO: Fix! It doesn't keep the alpha channel, it adds a black background
+ (UIImage *)grayImageForImage:(UIImage *)image
{
    // See http://incurlybraces.com/convert-transparent-image-to-grayscale-in-ios
    // Create a black & white version of the image
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;
    
    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    // Create an image mask taking only the alpha channel from the original image
    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, NULL, (CGBitmapInfo)kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a new image from the opaque image by masking it agains the image most recently created
    CGImageRef grayScale = CGImageCreateWithMask(grayImage, mask);
    UIImage *grayScaleImage = [UIImage imageWithCGImage:grayScale scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    return grayScaleImage;
}

+ (NSString *)normalizedString:(NSString *)string
{
    NSString *newString = [string decomposedStringWithCanonicalMapping];
    
    CFStringNormalize((CFMutableStringRef)newString, kCFStringNormalizationFormD);
    CFStringFold((CFMutableStringRef)newString, kCFCompareCaseInsensitive | kCFCompareDiacriticInsensitive | kCFCompareWidthInsensitive, NULL);
    CFStringTransform((CFMutableStringRef)newString, NULL, kCFStringTransformStripCombiningMarks, false);
    CFStringTransform((CFMutableStringRef)newString, NULL, kCFStringTransformStripDiacritics, false);
    
    return newString;
}

@end

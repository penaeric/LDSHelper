//
//  Person+AddOns.m
//  LDSHelper
//
//  Created by Eric Pena on 6/25/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Person+AddOns.h"
#import "Common.h"
#import "Companionship.h"

@implementation Person (AddOn)

- (void)prepareForDeletion
{
    if (self.isDeleted == YES && [self.companionedBy.companions count] == 1) {
        DDLogVerbose(@"Deleting Companionship from Person");
        [self.companionedBy deleteEntity];
    }
}

- (NSString *)initial
{
    [self willAccessValueForKey:@"initial"];
    NSString *initial = [self.normalizedName substringToIndex:1];
    [self didAccessValueForKey:@"initial"];
    return initial;
}

- (void) setLastName:(NSString *)newLastName
{
    [self willChangeValueForKey:@"lastName"];
    [self setPrimitiveValue:newLastName forKey:@"lastname"];
    [self didChangeValueForKey:@"lastName"];
    [self updateNormalizedName];
    [self updateInitials];
}

- (void) setFirstName:(NSString *)newFirstName
{
    [self willChangeValueForKey:@"firstName"];
    [self setPrimitiveValue:newFirstName forKey:@"firstName"];
    [self didChangeValueForKey:@"firstName"];
    [self updateNormalizedName];
    [self updateInitials];
}

- (void)updateNormalizedName
{
    NSString *normalizedString;
    if ([self.firstName length] > 0) {
        normalizedString = self.firstName;
    } else {
        normalizedString = self.lastName;
    }
    
    self.normalizedName = [Common normalizedString:normalizedString];
}

- (void)updateInitials
{
    NSString *initials = @"";
    if ([self.firstName length] > 0) {
        initials = [self.firstName substringToIndex:1];
    }
    if ([self.lastName length] > 0) {
        initials = [NSString stringWithFormat:@"%@%@", initials, [self.lastName substringToIndex:1]];
    }
    
    self.initials = [initials uppercaseString];
}

- (NSString *)fullName
{
    if ([self.firstName length] > 0 && [self.lastName length] > 0) {
        return [[NSString alloc] initWithFormat:@"%@, %@", self.lastName, self.firstName];
    }
    
    return [[NSString alloc] initWithFormat:@"%@%@", self.firstName, self.lastName];
}

- (NSString *)cityStateZipAddress
{
    // Could this be a transient property?
    NSMutableString *fullAddress = [[NSMutableString alloc] init];
    
    if (![self.city length] == 0 && ![self.state length] == 0) {
        DDLogVerbose(@"Appending city & state: {%@, %@} %d %d", self.city, self.state, [self.city length], [self.state length]);
        [fullAddress appendFormat:@"%@, %@", self.city, self.state];
    } else if (![self.city length] == 0) {
        DDLogVerbose(@"Appending city {%@} > %d", self.city, [self.city length]);
        [fullAddress appendFormat:@"%@ ", self.city];
    } else if (![self.state length] == 0) {
        DDLogVerbose(@"Appending state {%@}", self.state);
        [fullAddress appendFormat:@"%@", self.state];
    }
    
    if (![fullAddress length] == 0) {
        [fullAddress appendFormat:@" "];
    }
    
    if (![self.zipCode length] == 0) {
        [fullAddress appendFormat:@"%@", self.zipCode];
    }

    DDLogVerbose(@"Full Address: {%@}", [NSString stringWithString:fullAddress]);
    
    return [NSString stringWithString:fullAddress];
}

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    self.thumbnail = [Common thumbnailDataForImage:image
                                             width:kLDSImageWidth
                                            heigth:kLDSImageHeight
                                      cornerRadius:kLDSImageRadius];
}

- (void)setThumbnailSmallDataFromImage:(UIImage *)image
{
    self.thumbnailSmall = [Common thumbnailDataForImage:image
                                                  width:kLDSSmallImageWidth
                                                 heigth:kLDSSmallImageHeight
                                           cornerRadius:kLDSSmallImageRadius];
    
    UIImage *grayScaleImage = [Common grayImageForImage:[UIImage imageWithData:self.thumbnailSmall]];
    self.thumbnailGraySmall = UIImagePNGRepresentation(grayScaleImage);
}

@end

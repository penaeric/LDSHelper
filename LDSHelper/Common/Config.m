//
//  Config.m
//  LDSHelper
//
//  Created by Eric Pena on 7/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Config.h"
#import "UIColor+LDSColors.h"

@implementation Config

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedConfig];
}

+ (Config *)sharedConfig
{
    static Config *sharedConfig = nil;
    if (!sharedConfig) {
        sharedConfig = [[super allocWithZone:NULL] init];
    }
    return sharedConfig;
}


/**
 @param organizationName must be equal as one of the defined returned in CurrentOrganization_FullString
 */
+ (UIColor *)colorForOrganization:(NSString *)organizationName
{
    if ([CurrentOrganization_FullString[kLDSReliefSociety] isEqualToString:organizationName]) {
        return [UIColor orangeColor];
    }
    
    return [UIColor LDSBlueColor];
}


+ (UIColor *)colorForSelectedMenuForOrganization:(NSString *)organizationName
{
    if ([CurrentOrganization_FullString[kLDSReliefSociety] isEqualToString:organizationName]) {
        return [UIColor orangeColor];
    }
    
    return [UIColor LDSBlueMenuSelectedColor];
}


+ (UIColor *)colorForCurrentOrganization
{
    return [self colorForOrganization:[[Config sharedConfig] currentOrganization].name];
}


- (void)setCurrentOrganization:(Organization *)organization
{
    DDLogInfo(@"Setting the current organization to {%@}", organization.name);
    currentOrganization = organization;
}


- (Organization *)currentOrganization
{
    return currentOrganization;
}


/**
 Menu for each Organization
 
 @warning // Order has to match CurrentOrganization constants
 */
- (NSArray *)menus
{
    return @[
             @"",
             // Elders Quorum
             @[
                 @(kLDSMembersView),
                 @(kLDSAssistanceView),
                 @(kLDSCompanionshipsView),
                 @(kLDSHomeTeachingView),
                 @(kLDSReportsView),
                 @(kLDSEmptyView),
                 @(kLDSImportContactsView)
                 ],
             // Relief Society
             @[
                 @(kLDSMembersView),
                 @(kLDSAssistanceView),
                 @(kLDSCompanionshipsView),
                 @(kLDSHomeTeachingView),
                 @(kLDSReportsView),
                 @(kLDSEmptyView),
                 @(kLDSImportContactsView)
                 ]
             ];
}


- (NSDictionary *)navigationBarTitleAttributes
{
    return @{
             NSFontAttributeName: [UIFont fontWithName:kLDSFontBariolItalic size:26.0f],
             NSForegroundColorAttributeName : [UIColor whiteColor]
             };
}


- (Boolean)navigationBarTranslucency
{
    return YES;
}

@end

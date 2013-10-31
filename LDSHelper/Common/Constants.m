//
//  Constants.m
//  LDSHelper
//
//  Created by Eric Pena on 6/15/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const kLDSHasViewedIntro = @"HasViewedIntro";
NSString *const kLDSCurrentOrganization = @"CurrentOrganization";
NSString *const kLDSCurrentView = @"CurrentView";
NSString *const kLDSApplicationName = @"LDS Helper";

NSString *const kLDSFontBariolItalic = @"BariolRegular-Italic";
NSString *const kLDSFontBariolRegular = @"Bariol-Regular";

CGFloat const kLDSImageWidth = 180.;
CGFloat const kLDSImageHeight = 180.0;
CGFloat const kLDSImageRadius = 10;// 90.0;
CGFloat const kLDSSmallImageWidth = 108;
CGFloat const kLDSSmallImageHeight = 108;
CGFloat const kLDSSmallImageRadius = 12;//54;

CGFloat const kLDSHeightForGenericMemberCell = 74.0;

NSString *const kLDSHomeTeachingSelectedViewIndex = @"Home Teaching Selected View Index";

NSString *const CurrentOrganization_Str[] = {
    [kLDSEldersQuorum] = @"EldersQuorum",
    [kLDSReliefSociety] = @"ReliefSociety"
};

NSString *const CurrentOrganization_MenuId[] = {
    [kLDSEldersQuorum] = @"Menu Elders Quorum",
    [kLDSReliefSociety] = @"Menu Relief Society"
};

NSString *const CurrentOrganization_FullString[] = {
    [kLDSEldersQuorum] = @"Elders Quorum",
    [kLDSReliefSociety] = @"Relief Society"
};

NSString *const CurrentView_Str[] = {
    [kLDSMembersView] = @"Members",
    [kLDSAssistanceView] = @"Assistance",
    [kLDSCompanionshipsView] = @"Companionships",
    [kLDSHomeTeachingView] = @"HomeTeaching",
    [kLDSReportsView] = @"Reports",
    [kLDSImportContactsView] = @"ImportContacts"
};

NSString *const CurrentView_FullString[] = {
    [kLDSMembersView] = @"Members",
    [kLDSAssistanceView] = @"Assistance",
    [kLDSCompanionshipsView] = @"Companionships",
    [kLDSHomeTeachingView] = @"Home Teaching",
    [kLDSReportsView] = @"Reports",
    [kLDSImportContactsView] = @"Import Contacts"
};

NSString *const ReportType_Str[] = {
    [kLDSMembers] = @"Members",
    [kLDSAssistance] = @"Assistance",
    [kLDSCompanionships] = @"Companionships",
    [kLDSHomeTeaching] = @"HomeTeaching"
};

NSString *const ReportType_FullString[] = {
    [kLDSMembers] = @"Members",
    [kLDSAssistance] = @"Assistance",
    [kLDSCompanionships] = @"Companionships",
    [kLDSHomeTeaching] = @"Home Teaching"
};

@end

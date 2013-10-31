//
//  Constants.h
//  LDSHelper
//
//  Created by Eric Pena on 6/15/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@import Foundation;

@interface Constants : NSObject

extern NSString *const kLDSHasViewedIntro;
// Key used for Current Organization in the NSDefaults
extern NSString *const kLDSCurrentOrganization;
extern NSString *const kLDSCurrentView;
extern NSString *const kLDSApplicationName;

// Font Names
extern NSString *const kLDSFontBariolItalic;
extern NSString *const kLDSFontBariolRegular;

// Size for the thumbnail image
extern CGFloat const kLDSImageWidth;
extern CGFloat const kLDSImageHeight;
extern CGFloat const kLDSImageRadius;
// Size for the small thumbnail image
extern CGFloat const kLDSSmallImageWidth;
extern CGFloat const kLDSSmallImageHeight;
extern CGFloat const kLDSSmallImageRadius;

// Size of the GenericMemberCell
extern CGFloat const kLDSHeightForGenericMemberCell;

// Which index is selected for the SegmentedControl
extern NSString *const kLDSHomeTeachingSelectedViewIndex;

// TODO: rename to Organization?
typedef enum CurrentOrganization : NSUInteger {
    // Have to start with 1 as 0 will be equal to nil when doing comparisons
    kLDSEldersQuorum = 1,
    kLDSReliefSociety
} CurrentOrganization;

// Translators to CurrentOrganization
// USAGE: NSString *someString = CurrentOrganization_toString[kLDSEldersQuorum];
extern NSString *const CurrentOrganization_Str[];
extern NSString *const CurrentOrganization_MenuId[];
extern NSString *const CurrentOrganization_FullString[];

typedef enum CurrentView : NSInteger {
    kLDSEmptyView = -1,
    kLDSMembersView = 0,
    kLDSAssistanceView,
    kLDSCompanionshipsView,
    kLDSHomeTeachingView,
    kLDSReportsView,
    kLDSImportContactsView
} CurrentView;

extern NSString *const CurrentView_Str[];
extern NSString *const CurrentView_FullString[];

typedef enum ReportType : NSUInteger {
    kLDSMembers = 1,
    kLDSAssistance,
    kLDSCompanionships,
    kLDSHomeTeaching
} ReportType;

extern NSString *const ReportType_Str[];
extern NSString *const ReportType_FullString[];

@end

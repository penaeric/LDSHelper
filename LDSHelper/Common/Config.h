//
//  Config.h
//  LDSHelper
//
//  Created by Eric Pena on 7/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Organization.h"

@interface Config : NSObject
{
    Organization *currentOrganization;
}

+ (Config *)sharedConfig;
+ (UIColor *)colorForOrganization:(NSString *)organizationName;
+ (UIColor *)colorForCurrentOrganization;
+ (UIColor *)colorForSelectedMenuForOrganization:(NSString *)organizationName;

- (void)setCurrentOrganization:(Organization *)organization;
- (Organization *)currentOrganization;
- (NSArray *)menus;
- (NSDictionary *)navigationBarTitleAttributes;
- (Boolean)navigationBarTranslucency;

@end

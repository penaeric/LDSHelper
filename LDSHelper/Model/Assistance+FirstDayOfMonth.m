//
//  Assistance+FirstDayOfMonth.m
//  LDSHelper
//
//  Created by Eric Pena on 8/29/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Assistance+FirstDayOfMonth.h"
#import "NSDate+Reporting.h"

@implementation Assistance (FirstDayOfMonth)

// Needed for Monthly reports
- (void)setDate:(NSDate *)date
{
    [self willChangeValueForKey:@"date"];
    [self setPrimitiveValue:date forKey:@"date"];
    [self didChangeValueForKey:@"date"];
    self.firstDayOfMonth = [NSDate firstDayOfMonth:date];
}

@end

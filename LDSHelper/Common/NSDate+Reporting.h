//
//  NSDate+Reporting.h
//  LDSHelper
//
//  Created by Eric Pena on 8/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//


@interface NSDate (Reporting)

+ (NSDate *)firstDayOfMonth;
+ (NSDate *)firstDayOfMonth:(NSDate *)date;
+ (NSDate *)firstDayOfMonth:(NSDate *)date byAddingMonths:(NSInteger)numberOfMonths;

@end

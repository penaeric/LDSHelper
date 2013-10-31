//
//  NSDate+Reporting.m
//  LDSHelper
//
//  Created by Eric Pena on 8/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "NSDate+Reporting.h"

@implementation NSDate (Reporting)

+ (NSDate *)firstDayOfMonth
{
    return [self firstDayOfMonth:[NSDate date]];
}

+ (NSDate *)firstDayOfMonth:(NSDate *)date
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSCalendarCalendarUnit
                                                        fromDate:date];
    
    [components setDay:1];

    [self zeroOutTimeComponents:&components];
    
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfMonth:(NSDate *)date byAddingMonths:(NSInteger)numberOfMonths
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *addingComponent = [[NSDateComponents alloc] init];
    [addingComponent setMonth:numberOfMonths];
    
    NSDate *dateToReturn = [gregorianCalendar dateByAddingComponents:addingComponent
                                                              toDate:[self firstDayOfMonth:date]
                                                             options:0];
    
    return dateToReturn;
}

+ (void)zeroOutTimeComponents:(NSDateComponents **)components
{
    [*components setHour:12];
    [*components setMinute:0];
    [*components setSecond:0];
}

@end

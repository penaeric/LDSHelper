//
//  DayPickerVC.m
//  LDSHelper
//
//  Created by Eric Pena on 7/25/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "DayPickerVC.h"

@interface DayPickerVC () <MZDayPickerDelegate, MZDayPickerDataSource>

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

// TODO: Write my own Day Picker using the a Collection View trying to keep the same interface as MZDayPicker
@implementation DayPickerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupDayPicker];
}

- (void)setupDayPicker
{
    if (!self.startDate) {
        self.startDate = [NSDate date];
    }
    if (!self.endDate) {
        self.endDate = [NSDate date];
    }
    if (!self.currentDate) {
        self.currentDate = [NSDate date];
    }
    
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter  setDateFormat:@"EE"];
    
    [self.dayPicker setStartDate:self.startDate
                         endDate:self.endDate];
    
    [self.dayPicker setCurrentDate:self.currentDate
                          animated:NO];
    
    [self.delegate didSelectDate:[NSDate date]];
}

- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dateFormatter stringFromDate:day.date];
}

- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    NSDateFormatter *selectDateFormatter = [[NSDateFormatter alloc] init];
    [selectDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLog(@"Did select day %@, {%@}", day.day, [selectDateFormatter stringFromDate:day.date]);
    
    [self.delegate didSelectDate:day.date];
}

@end

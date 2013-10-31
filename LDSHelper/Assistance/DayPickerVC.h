//
//  DayPickerVC.h
//  LDSHelper
//
//  Created by Eric Pena on 7/25/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MZDayPicker.h"

@class DayPickerVC;

@protocol DayPickerDelegate <NSObject>

@required
- (void)didSelectDate:(NSDate *)date;

@end

@interface DayPickerVC : UIViewController

@property (weak, nonatomic) IBOutlet MZDayPicker *dayPicker;
@property (weak, nonatomic) id<DayPickerDelegate> delegate;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *currentDate;

@end

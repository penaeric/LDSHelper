//
//  MonthNavigatorVC.h
//  LDSHelper
//
//  Created by Eric Pena on 8/20/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@class MonthNavigatorVC;

@protocol MonthNavigatorDelegate <NSObject>

-(void)didSelectDate:(NSDate *)date;

@end

@interface MonthNavigatorVC : UIViewController

@property (weak, nonatomic) id<MonthNavigatorDelegate> delegate;

@end

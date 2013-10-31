//
//  HomeTeachingReportEditTVC.h
//  LDSHelper
//
//  Created by Eric Pena on 8/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Companionship.h"

@class HomeTeachingReportEditTVC;


@protocol HomeTeachingReportDelegate <NSObject>

- (void)updatedVisit:(HomeTeachingReportEditTVC *)controller;
- (void)deletedVisit:(HomeTeachingReportEditTVC *)controller;

@end


@interface HomeTeachingReportEditTVC : UITableViewController

@property (weak, nonatomic) id<HomeTeachingReportDelegate> delegate;

@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) Companionship *companionship;
@property (assign, nonatomic) BOOL isCompanionshipView;

@end

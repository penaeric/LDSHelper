//
//  ReportViewerVC.h
//  LDSHelper
//
//  Created by Eric Pena on 8/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Report.h"

@class ReportViewerVC;

@protocol ReportViewerProtocol <NSObject>

- (void)deletedReport:(ReportViewerVC *)controller;

@end

@interface ReportViewerVC : UIViewController

@property (strong, nonatomic) Report *report;
@property (nonatomic) ReportType reportType;
@property (weak, nonatomic) id<ReportViewerProtocol> delegate;

@end

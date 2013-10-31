//
//  BaseReport.h
//  LDSHelper
//
//  Created by Eric Pena on 8/17/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@class BaseReport;

@protocol ReportProtocol <NSObject>

@optional
- (void)addHeader;
- (void)addFooter;
- (void)beginPDFPages;

@required
- (void)setupData;
- (void)beginPDFPageWithIndex:(NSUInteger)index;

@end


@interface BaseReport : NSObject

// This should not be exposed, is there a work around?
@property CGSize pageSize;

- (NSString *)createReportWithDate:(NSDate *)date;
- (NSString *)createReportWithDate:(NSDate *)date andPageSize:(CGSize)pageSize;
- (void)addLineWithFrame:(CGRect)frame withColor:(UIColor *)color;
- (void)addImage:(UIImage *)image atPoint:(CGPoint)point;
- (void)createPDFPage;

@end

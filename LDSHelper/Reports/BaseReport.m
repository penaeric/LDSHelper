//
//  BaseReport.m
//  LDSHelper
//
//  Created by Eric Pena on 8/17/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "BaseReport.h"

@interface BaseReport()

@property (strong, nonatomic) NSDate *reportDate;

/**
 / Should be set during setupData:
 */
@property (strong, nonatomic, readonly) NSString *reportName;
@property (nonatomic, readonly) NSInteger padding;

@end

@implementation BaseReport

- (id)init
{
    self = [super init];
    if (self) {
        // Set up default page size
        self.pageSize = CGSizeMake(612, 792);
    }
    
    return self;
}

#pragma mark - Base Common Methods

- (NSString *)createReportWithDate:(NSDate *)date
{
    return [self createReportWithDate:date andPageSize:self.pageSize];
}

- (NSString *)createReportWithDate:(NSDate *)date andPageSize:(CGSize)pageSize
{
    self.pageSize = pageSize;
    
    if (self.pageSize.width <= 0) {
        self.pageSize = CGSizeMake(612, self.pageSize.height);
    }
    if (self.pageSize.height <= 0) {
        self.pageSize = CGSizeMake(self.pageSize.width, 792);
    }
    
    self.reportDate = date;
    [self setupData];
    NSString *path = [self pathForNewDocument];
    [self beginPDFPages];
    [self finishPDF];
    
    return path;
}

- (NSString *)pathForNewDocument
{
    NSLog(@"Base pathForNewDocumentNamed with Name: %@", self.reportName);
    
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", self.reportName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                          NSUserDomainMask,
                                                          YES);
    NSString *documentDirectory = paths[0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:newPDFName];
    NSLog(@"pdfPath: %@", path);
    
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
    
    return path;
}

- (void)beginPDFPages
{
    [self beginPDFPageWithIndex:0];
}

- (void)createPDFPage
{
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, self.pageSize.width, self.pageSize.height), nil);
}

- (void)finishPDF
{
    UIGraphicsEndPDFContext();
}

- (void)addLineWithFrame:(CGRect)frame withColor:(UIColor *)color
{
    DDLogVerbose(@"BASE:adding line");
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    
    // this is the thicknes of the line
    CGContextSetLineWidth(currentContext, frame.size.height);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
    
    // Draw
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}

- (void)addImage:(UIImage *)image atPoint:(CGPoint)point
{
    NSLog(@"BASE:adding Image");
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
}

#pragma mark - Not implemented methods
// They're here only to make them available to the Base class, should be overriden by the protocol
- (void)setupData
{
    NSAssert(true, @"Method not implemented");
}

- (void)beginPDFPageWithIndex:(NSInteger)index
{
    NSAssert(true, @"Method not implemented");
}

@end

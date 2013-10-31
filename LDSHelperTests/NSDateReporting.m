//
//  NSDateReporting.m
//  LDSHelper
//
//  Created by Eric Pena on 8/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+Reporting.h"

@interface NSDateReporting : XCTestCase

@property (strong, nonatomic) NSDate *date;

@end

@implementation NSDateReporting

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end

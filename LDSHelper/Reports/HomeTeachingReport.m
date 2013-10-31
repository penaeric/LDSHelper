//
//  HomeTeaching.m
//  LDSHelper
//
//  Created by Eric Pena on 8/17/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "HomeTeachingReport.h"

@interface HomeTeachingReport()

@property (strong, nonatomic, readwrite) NSString *reportName;
@property (nonatomic, readwrite) NSInteger padding;
@property (strong, nonatomic) NSArray *items;

@end

@implementation HomeTeachingReport

- (void)setupData
{
    self.reportName = @"Assistance Report"; // Add date or something
    self.padding = 20;
    self.items = @[@"Rob Stark", @"John Stark", @"Arya Stark", @"Sansa Stark", @"Ned Stark", @"Lady Stark"];
    NSLog(@"HomeTeaching setupData");
}

- (void)beginPDFPageWithIndex:(NSInteger)index
{
    NSLog(@"Assistance: beginPDFPageWithIndex");
    [self createPDFPage];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10],
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSBackgroundColorAttributeName: [UIColor blackColor]};
    NSLog(@"%@", self.items[0]);
    NSAttributedString *attributtedString = [[NSAttributedString alloc]
                                             initWithString:self.items[0]
                                             attributes:attributes];
    CGSize size = [attributtedString size];
    
    CGPoint point = CGPointMake(self.padding, self.padding);
    
    for (NSInteger i = index; i < [self.items count]; i++) {
        attributtedString = [[NSAttributedString alloc]
                             initWithString:self.items[i]
                             attributes:attributes];
        CGFloat y = point.y + (i * (size.height + 10));
        [attributtedString drawAtPoint:CGPointMake(self.padding, y)];
        
        [self addLineWithFrame:CGRectMake(self.padding,
                                          y + size.height,
                                          self.pageSize.width - self.padding * 2,
                                          1)
                     withColor:[UIColor grayColor]];
    }
}

@end

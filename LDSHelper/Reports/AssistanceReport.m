//
//  AssistanceReport.m
//  LDSHelper
//
//  Created by Eric Pena on 8/17/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "AssistanceReport.h"

@interface AssistanceReport()

@property (strong, nonatomic, readwrite) NSString *reportName;
@property (nonatomic, readwrite) NSInteger padding;
@property (strong, nonatomic) NSArray *assistances;

@end

@implementation AssistanceReport

- (void)setupData
{
    self.reportName = @"Assistance Report"; // Add date or something
    self.padding = 20;
    self.assistances = @[@"Mariah Carey", @"Michael Jordan", @"Adriana Lima", @"Twyin Lannister", @"Ned Stark"];
    NSLog(@"Assistance setupData");
}

- (void)beginPDFPages
{
    [self addHeader];
    [self beginPDFPageWithIndex:0];
    [self beginPDFPageWithIndex:3];
    
    // NSInteger currentIndex
    // currentIndex = [printItems]; // Print items returns the last item it was able to print in the current page
    // while (currentIndex + 1 < [data count])
    //        currentIndex = beginPDFPageWithIndex:currentIndex
}

- (void)beginPDFPageWithIndex:(NSUInteger)index
{
    NSLog(@"Assistance: beginPDFPageWithIndex");
    [self createPDFPage];
    [self addHeader];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10],
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor grayColor]};
    NSLog(@"%@", self.assistances[0]);
    NSAttributedString *attributtedString = [[NSAttributedString alloc]
                                             initWithString:self.assistances[0]
                                             attributes:attributes];
    CGSize size = [attributtedString size];
    
    CGPoint point = CGPointMake(self.padding, self.padding);
    
    for (NSInteger i = index; i < [self.assistances count]; i++) {
        attributtedString = [[NSAttributedString alloc]
                             initWithString:self.assistances[i]
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

- (void)addHeader
{
    UIImage *anImage = [UIImage imageNamed:@"tree.jpg"];
    [self addImage:anImage atPoint:CGPointMake(self.padding, self.padding)];
}

@end

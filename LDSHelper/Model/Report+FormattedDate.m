//
//  Report+FormattedDate.m
//  LDSHelper
//
//  Created by Eric Pena on 8/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Report+FormattedDate.h"

@implementation Report (FormattedDate)

- (NSString *)formattedDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy MMMM"];
    
    return [dateFormatter stringFromDate:self.date];
}

@end

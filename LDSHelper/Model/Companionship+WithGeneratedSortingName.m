//
//  Companionship+WithGeneratedSortingName.m
//  LDSHelper
//
//  Created by Eric Pena on 8/4/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Companionship+WithGeneratedSortingName.h"
#import "Person.h"
#import "Common.h"

@implementation Companionship (WithGeneratedSortingName)

- (void)setSortingName:(NSString *)sortingName
{
    NSAssert([self.companions count] > 0, @"I need companions to generate a sortingName");
    
    [self willChangeValueForKey:@"sortingName"];
    
    Person *firstCompanion = [self.companions firstObject];
    NSString *firstCompanionName = ([firstCompanion.lastName length] > 0) ? firstCompanion.lastName : firstCompanion.firstName;
    firstCompanionName = [Common normalizedString:firstCompanionName];

    if ([self.companions count] > 1) {
        Person *secondCompanion = [self.companions objectAtIndex:1];
        NSString *secondCompanionName = ([secondCompanion.lastName length] > 0) ? secondCompanion.lastName : secondCompanion.firstName;
        secondCompanionName = [Common normalizedString:secondCompanionName];
        [self setPrimitiveValue:[NSString stringWithFormat:@"%@ %@", firstCompanionName, secondCompanionName]
                         forKey:@"sortingName"];
    } else {
        [self setPrimitiveValue:firstCompanionName forKey:@"sortingName"];
    }
    
    self.initial = [[Common normalizedString:self.sortingName] substringToIndex:1];
    
    [self didChangeValueForKey:@"sortingName"];
}

@end

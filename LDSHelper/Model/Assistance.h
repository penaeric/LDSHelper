//
//  Assistance.h
//  LDSHelper
//
//  Created by Eric Pena on 8/29/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Organization, Person;

@interface Assistance : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * firstDayOfMonth;
@property (nonatomic, retain) Organization *organization;
@property (nonatomic, retain) NSSet *persons;
@end

@interface Assistance (CoreDataGeneratedAccessors)

- (void)addPersonsObject:(Person *)value;
- (void)removePersonsObject:(Person *)value;
- (void)addPersons:(NSSet *)values;
- (void)removePersons:(NSSet *)values;

@end

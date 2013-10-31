//
//  Companionship.h
//  LDSHelper
//
//  Created by Eric Pena on 9/11/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Organization, Person, Visit;

@interface Companionship : NSManagedObject

@property (nonatomic, retain) NSString * initial;
@property (nonatomic, retain) NSString * sortingName;
@property (nonatomic, retain) NSOrderedSet *companions;
@property (nonatomic, retain) NSSet *inOrganization;
@property (nonatomic, retain) NSSet *visitRecords;
@property (nonatomic, retain) NSOrderedSet *visits;
@end

@interface Companionship (CoreDataGeneratedAccessors)

- (void)insertObject:(Person *)value inCompanionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCompanionsAtIndex:(NSUInteger)idx;
- (void)insertCompanions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCompanionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCompanionsAtIndex:(NSUInteger)idx withObject:(Person *)value;
- (void)replaceCompanionsAtIndexes:(NSIndexSet *)indexes withCompanions:(NSArray *)values;
- (void)addCompanionsObject:(Person *)value;
- (void)removeCompanionsObject:(Person *)value;
- (void)addCompanions:(NSOrderedSet *)values;
- (void)removeCompanions:(NSOrderedSet *)values;
- (void)addInOrganizationObject:(Organization *)value;
- (void)removeInOrganizationObject:(Organization *)value;
- (void)addInOrganization:(NSSet *)values;
- (void)removeInOrganization:(NSSet *)values;

- (void)addVisitRecordsObject:(Visit *)value;
- (void)removeVisitRecordsObject:(Visit *)value;
- (void)addVisitRecords:(NSSet *)values;
- (void)removeVisitRecords:(NSSet *)values;

- (void)insertObject:(Person *)value inVisitsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromVisitsAtIndex:(NSUInteger)idx;
- (void)insertVisits:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeVisitsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInVisitsAtIndex:(NSUInteger)idx withObject:(Person *)value;
- (void)replaceVisitsAtIndexes:(NSIndexSet *)indexes withVisits:(NSArray *)values;
- (void)addVisitsObject:(Person *)value;
- (void)removeVisitsObject:(Person *)value;
- (void)addVisits:(NSOrderedSet *)values;
- (void)removeVisits:(NSOrderedSet *)values;
@end

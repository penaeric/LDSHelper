//
//  Organization.h
//  LDSHelper
//
//  Created by Eric Pena on 8/27/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assistance, Companionship, Person;

@interface Organization : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *assistance;
@property (nonatomic, retain) NSSet *companionships;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSSet *reports;
@end

@interface Organization (CoreDataGeneratedAccessors)

- (void)addAssistanceObject:(Assistance *)value;
- (void)removeAssistanceObject:(Assistance *)value;
- (void)addAssistance:(NSSet *)values;
- (void)removeAssistance:(NSSet *)values;

- (void)addCompanionshipsObject:(Companionship *)value;
- (void)removeCompanionshipsObject:(Companionship *)value;
- (void)addCompanionships:(NSSet *)values;
- (void)removeCompanionships:(NSSet *)values;

- (void)addMembersObject:(Person *)value;
- (void)removeMembersObject:(Person *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

- (void)addReportsObject:(NSManagedObject *)value;
- (void)removeReportsObject:(NSManagedObject *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;

@end

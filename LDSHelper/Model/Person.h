//
//  Person.h
//  LDSHelper
//
//  Created by Eric Pena on 9/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assistance, Companionship, Organization, Visit;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * initial;
@property (nonatomic, retain) NSString * initials;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * mobilePhone;
@property (nonatomic, retain) NSString * normalizedName;
@property (nonatomic, retain) NSString * primaryPhone;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSData * thumbnailSmall;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSData * thumbnailGraySmall;
@property (nonatomic, retain) NSSet *assistance;
@property (nonatomic, retain) Companionship *companionedBy;
@property (nonatomic, retain) Organization *memberOf;
@property (nonatomic, retain) Companionship *visitedBy;
@property (nonatomic, retain) NSSet *visitedRecords;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addAssistanceObject:(Assistance *)value;
- (void)removeAssistanceObject:(Assistance *)value;
- (void)addAssistance:(NSSet *)values;
- (void)removeAssistance:(NSSet *)values;

- (void)addVisitedRecordsObject:(Visit *)value;
- (void)removeVisitedRecordsObject:(Visit *)value;
- (void)addVisitedRecords:(NSSet *)values;
- (void)removeVisitedRecords:(NSSet *)values;

@end

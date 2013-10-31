//
//  Visit.h
//  LDSHelper
//
//  Created by Eric Pena on 9/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Companionship, Person;

@interface Visit : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) Companionship *companionship;
@property (nonatomic, retain) NSSet *visited;
@end

@interface Visit (CoreDataGeneratedAccessors)

- (void)addVisitedObject:(Person *)value;
- (void)removeVisitedObject:(Person *)value;
- (void)addVisited:(NSSet *)values;
- (void)removeVisited:(NSSet *)values;

@end

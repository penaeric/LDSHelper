//
//  Report.h
//  LDSHelper
//
//  Created by Eric Pena on 9/4/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Organization;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSData * file;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) Organization *forOrganization;

@end

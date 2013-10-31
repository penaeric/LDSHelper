//
//  EditMemberTVC.h
//  LDSHelper
//
//  Created by Eric Pena on 6/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Person+AddOns.h"

@class MemberEditTVC;

@protocol EditMemberDelegate <NSObject>

@optional
- (void)updatedPerson:(Person *)person;
- (void)aNewMemberWasCreated:(MemberEditTVC *)controller;

@end

@interface MemberEditTVC : UITableViewController

@property (nonatomic, strong) Person *person;

@property (nonatomic, weak) id<EditMemberDelegate> delegate;

@end

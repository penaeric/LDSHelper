//
//  CompanionshipEditTVC.h
//  LDSHelper
//
//  Created by Eric Pena on 8/5/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Companionship.h"

@class CompanionshipEditTVC;

@protocol EditCompanionshipDelegate <NSObject>

@optional
- (void)updatedCompanionship:(CompanionshipEditTVC *)controller;
- (void)aNewCompanionshipWasCreated:(CompanionshipEditTVC *)controller;
- (void)editingWasCancelled:(CompanionshipEditTVC *)controller;

@end

@interface CompanionshipEditTVC : UITableViewController

@property (strong, nonatomic) Companionship *companionship;

@property (weak, nonatomic) id<EditCompanionshipDelegate> delegate;

@end

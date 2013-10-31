//
//  CompanionshipDetailTVC.h
//  LDSHelper
//
//  Created by Eric Pena on 8/4/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Companionship.h"

@class CompanionshipDetailTVC;

@protocol CompanionshipDetailDelegate <NSObject>

@required;
- (void)deletedCompanionship:(CompanionshipDetailTVC *)controller;

@end

@interface CompanionshipDetailTVC : UITableViewController

@property (strong, nonatomic) Companionship *companionship;

@property (weak, nonatomic) id<CompanionshipDetailDelegate>delegate;

@end

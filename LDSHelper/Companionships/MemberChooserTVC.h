//
//  MemberChooserTVC.h
//  LDSHelper
//
//  Created by Eric Pena on 8/6/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Person+AddOns.h"

@class MemberChooserTVC;

@protocol MemberChooserDelegate <NSObject>

@required
- (void)choosePerson:(MemberChooserTVC *)controller;

@end

@interface MemberChooserTVC : CoreDataTableViewController

@property (assign, nonatomic) BOOL isCompanionChooser;
@property (strong, nonatomic) Person *personChosen;

@property (weak, nonatomic) id<MemberChooserDelegate> delegate;

@end

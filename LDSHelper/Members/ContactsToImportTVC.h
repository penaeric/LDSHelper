//
//  ContactsToImportTVC.h
//  LDSHelper
//
//  Created by Eric Pena on 7/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@import AddressBook;
@import AddressBookUI;
#import "Organization.h"

@class ContactsToImportTVC;

@protocol ContactsToImportDelegate <NSObject>

- (void)contactsWereImported:(ContactsToImportTVC *)controller
                    imported:(NSInteger)imported
                     skipped:(NSInteger)skipped;

@end

@interface ContactsToImportTVC : UITableViewController

@property (nonatomic, weak) id <ContactsToImportDelegate> delegate;
@property (strong, nonatomic) Organization *organization;
@property (assign, nonatomic) BOOL skipDuplicates;

@end

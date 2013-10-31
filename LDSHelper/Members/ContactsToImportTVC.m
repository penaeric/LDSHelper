//
//  ContactsToImportTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 7/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "ContactsToImportTVC.h"
#import "Person.h"
#import "TSMessage.h"

@interface ContactsToImportTVC ()

@property (strong, nonatomic) NSArray *people;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *container;
@property (nonatomic) NSInteger counter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;

@end

@implementation ContactsToImportTVC


- (void)viewDidLoad
{
    [super viewDidLoad];

    ddLogLevel = LOG_LEVEL_VERBOSE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
    
    [self setupView];
}

- (void)setupView
{
    self.importButton.enabled = NO;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        // First time access
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"First time access to AddressBook has been granted!");
                [self loadContacts];
                [self.tableView reloadData];
            } else {
                [self showNeedAddressBookAccessAlert];
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access
        [self loadContacts];
    } else {
        // The user has previously denied access
        [self showNeedAddressBookAccessAlert];
    }
    
    self.counter = 0;
}

- (void)loadContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    self.people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
}

// TODO: Test in device, takes long to show when first time deny access
- (void)showNeedAddressBookAccessAlert
{
    [TSMessage showNotificationInViewController:self
                                          title:@"Authorization Required"
                                       subtitle:@"You need to grant access to your contacts.  You can do this by going to the Privacy Settings in the Settings app"
                                          image:nil
                                           type:TSMessageNotificationTypeWarning
                                       duration:TSMessageNotificationDurationEndless
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:NO];
}

- (IBAction)importContacts:(id)sender
{
    [self showActivityIndicator];
    NSInteger imported = 0;
    NSInteger skipped = 0;
    
    for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            ABRecordRef person = (ABRecordRef)CFBridgingRetain(self.people[indexPath.row]);
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            Person *personToEdit = [self getPersonToEditWithFirstName:firstName lasName:lastName];
            
            if (personToEdit) {
                NSArray *phones = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty));
                NSArray *emails = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty));
                NSArray *address = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonAddressProperty));
            
                personToEdit.memberOf = self.organization;
                personToEdit.firstName = firstName;
                personToEdit.lastName = lastName;
            
                if ([phones count] > 0) {
                    personToEdit.primaryPhone = phones[0];
                }
                if ([phones count] >= 2) {
                    personToEdit.mobilePhone = phones[1];
                }
                if ([emails count] > 0) {
                    personToEdit.email = emails[0];
                }
                if ([address count]) {
                    NSDictionary *addressDict = address[0];
                    personToEdit.streetAddress = addressDict[@"Street"];
                    personToEdit.city = addressDict[@"City"];
                    personToEdit.state = addressDict[@"State"];
                    personToEdit.zipCode = addressDict[@"ZIP"];
                }
                
                imported++;
                
                DDLogInfo(@"> > > Imported: {%@, %@}", lastName, firstName);
            } else {
                skipped++;
                DDLogInfo(@"> > > Skipped: {%@, %@}", lastName, firstName);
            }
        }
    }
    
    [[NSManagedObjectContext defaultContext] saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            DDLogError(@"Error saving in default context: %@", [error localizedDescription]);
        }
        [self.delegate contactsWereImported:self
                                   imported:imported
                                    skipped:skipped];
    }];
}

- (Person *)getPersonToEditWithFirstName:(NSString *)firsName lasName:(NSString *)lastName
{
    Person *personToReturn;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(firstName == %@ AND lastName == %@)", firsName, lastName];
    Person *person = [Person findFirstWithPredicate:predicate];
    
    if (person && !self.skipDuplicates) {
        [person deleteEntity];
        personToReturn = [Person createEntity];
    } else if (!person) {
        personToReturn = [Person createEntity];
    }
    
    return personToReturn;
}

- (NSString *)getDisplayNameWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    if ([firstName length] > 0 && [lastName length] > 0) {
        return [[NSString alloc] initWithFormat:@"%@, %@", lastName, firstName];
    }
    
    return [[NSString alloc] initWithFormat:@"%@%@", firstName, lastName];
}

- (void)showActivityIndicator
{
    self.tableView.userInteractionEnabled = NO;
    if (!self.container) {
        self.container = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.activityIndicator setCenter:[self.container center]];
    self.container.backgroundColor = [UIColor blackColor];
    self.container.alpha = 0.75;
    [self.container addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.container];
}

- (void)hideActivityIndicator
{
    [self.container removeFromSuperview];
    self.tableView.userInteractionEnabled = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Contact Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ABRecordRef person = (ABRecordRef)CFBridgingRetain(self.people[indexPath.row]);
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    cell.textLabel.text = [self getDisplayNameWithFirstName:firstName lastName:lastName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        self.counter--;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.counter++;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    self.title = [NSString stringWithFormat:@"%i Contacts", self.counter];
    
    if (self.counter > 0) {
        self.importButton.enabled = YES;
    } else {
        self.importButton.enabled = NO;
    }
}

@end

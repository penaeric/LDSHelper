//
//  EditMemberTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 6/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@import AddressBook;
@import AddressBookUI;
#import "MemberEditTVC.h"
#import "Common.h"
#import "Organization.h"
#import "UITextField+Extended.h"
#import "TSMessage.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+LDSColors.h"

@interface MemberEditTVC () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *primaryPhoneField;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *streetAddressField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (weak, nonatomic) IBOutlet UIButton *organizationButton;
@property (weak, nonatomic) IBOutlet UIButton *importContactsButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *organizationCell;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *backgroundNameLabel;

@property (nonatomic, strong) NSArray *organizations;
@property (strong, nonatomic) Organization *selectedOrganization;

@property (assign, nonatomic) CGFloat organizationCellHeight;
@property (assign, nonatomic) BOOL isPickerSelected;

@property (assign, nonatomic) BOOL hasThumbnailChanged;

@property (retain, nonatomic) ABPeoplePickerNavigationController *contacts;

@end

@implementation MemberEditTVC


@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    ddLogLevel = LOG_LEVEL_WARN;
    [self setupView];
}

- (void)setupView
{
    DDLogVerbose(@"MemberEditTVC::Person: %@ %@", self.person.firstName, self.person.lastName);
    
    [self.firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.isPickerSelected = NO;
    self.organizationCellHeight = 44.0;
    self.hasThumbnailChanged = NO;
    [self.tableView setAllowsSelection:YES];
    [self loadOrganizations];
    [self setupNextTextFields];
    
    self.thumbnailImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailImageView.layer.borderWidth = 1.5;
    self.thumbnailImageView.layer.cornerRadius = 5;
    
    if (self.person) {
        // Populate Form Fields
        self.firstNameField.text = self.person.firstName;
        self.lastNameField.text = self.person.lastName;
        self.backgroundNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
        [self.organizationButton setTitle:self.person.memberOf.name forState:UIControlStateNormal];
        self.selectedOrganization = self.person.memberOf;
        self.primaryPhoneField.text = self.person.primaryPhone;
        self.mobilePhoneField.text = self.person.mobilePhone;
        self.emailField.text = self.person.email;
        self.streetAddressField.text = self.person.streetAddress;
        self.cityField.text = self.person.city;
        self.stateField.text = self.person.state;
        self.zipcodeField.text = self.person.zipCode;
        if (self.person.thumbnail) {
            self.thumbnailImageView.image = [UIImage imageWithData:self.person.thumbnail];
            self.backgroundImage.image = [[UIImage imageWithData:self.person.thumbnail] applyLightEffect];
        } else {
            self.thumbnailImageView.image = [UIImage imageNamed:@"thumbnail_no_contact_placeholder"];
            NSString *imageName = [NSString stringWithFormat:@"default_member_background_%@", CurrentOrganization_Str[kLDSEldersQuorum]];
            self.backgroundImage.image = [[UIImage imageNamed:imageName] applyLightEffect];
        }
        
        self.importContactsButton.hidden = YES;
        
    } else {
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
        self.navigationItem.rightBarButtonItem = saveButton;
        self.navigationItem.title = @"New Member";
        
        self.selectedOrganization = [[Config sharedConfig] currentOrganization];
        [self.organizationButton setTitle:self.selectedOrganization.name forState:UIControlStateNormal];
        
        self.thumbnailImageView.image = [UIImage imageNamed:@"thumbnail_no_contact_placeholder"];
        NSString *imageName = [NSString stringWithFormat:@"default_member_background_%@", CurrentOrganization_Str[kLDSEldersQuorum]];
        self.backgroundImage.image = [[UIImage imageNamed:imageName] applyLightEffect];
    }
}

- (void)loadOrganizations
{
    if (!self.organizations) {
        self.organizations = [Organization findAllSortedBy:@"name" ascending:YES];
    }
}

- (void)textFieldDidChange:(UITextField *)sender
{
    self.backgroundNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.firstNameField.text, self.lastNameField.text];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    if ([self.firstNameField.text length] == 0 && [self.lastNameField.text length] == 0) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [TSMessage showNotificationInViewController:self
                                              title:@"Name Needed"
                                           subtitle:@"Enter the First Name or Last Name"
                                               type:TSMessageNotificationTypeError];
        
        return;
    }
    
    if (!self.person) {
        self.person = [Person createEntity];
    }
    // Confugure Person
    self.person.firstName = self.firstNameField.text;
    self.person.lastName = self.lastNameField.text;
    self.person.primaryPhone = self.primaryPhoneField.text;
    self.person.mobilePhone = self.mobilePhoneField.text;
    self.person.email = self.emailField.text;
    self.person.streetAddress = self.streetAddressField.text;
    self.person.city = self.cityField.text;
    self.person.state = self.stateField.text;
    self.person.zipCode = self.zipcodeField.text;
    if (self.selectedOrganization) {
        self.person.memberOf = self.selectedOrganization;
    } else {
        DDLogVerbose(@"Saving with default Organization!!!");
        self.person.memberOf = [self.organizations objectAtIndex:0];
    }
    if (self.hasThumbnailChanged) {
        [self.person setThumbnailDataFromImage:self.thumbnailImageView.image];
        [self.person setThumbnailSmallDataFromImage:self.thumbnailImageView.image];
    }
    
    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    
    if (self.presentingViewController != nil) {
        // Dismiss View Controller that was presented modally
        [self.delegate aNewMemberWasCreated:self];
    } else {
        // Pop View Controller from navigation stack
        [delegate updatedPerson:self.person];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)organizationButtonPressed:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self.view endEditing:YES];
    
    if (cell == self.organizationCell && self.isPickerSelected == NO) {
        // Show Organization Picker
        self.isPickerSelected = YES;
        UIPickerView *organizationPicker = [[UIPickerView alloc] init];
        organizationPicker.delegate = self;
        organizationPicker.alpha = 0;
        organizationPicker.frame = CGRectMake(0, 44, 320, 216);
        if (self.selectedOrganization) {
            NSUInteger index = [self.organizations indexOfObject:self.selectedOrganization];
            [organizationPicker selectRow:index inComponent:0 animated:NO];
        }
        [self.tableView beginUpdates];
        self.organizationCellHeight = 44. + 217;
        [self.tableView endUpdates];
        [cell.contentView addSubview:organizationPicker];
        [UIView animateWithDuration:0.2
                         animations:^{
                             organizationPicker.alpha = 1;
                             UIColor *color = [Config colorForOrganization:
                                               [[Config sharedConfig] currentOrganization].name];
                             [self.organizationButton setTitleColor:color forState:UIControlStateNormal];
                         } completion:nil];
    } else {
        // Hide Organization Picker
        self.isPickerSelected = NO;
        
        UIPickerView *organizationPicker;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UIPickerView class]]) {
                organizationPicker = (UIPickerView *)view;
            }
        }
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             organizationPicker.alpha = 0;
                             [self.organizationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                         }
                         completion:^(BOOL finished){
                             [organizationPicker removeFromSuperview];
                         }];
        [self.tableView beginUpdates];
        self.organizationCellHeight = 44.;
        [self.tableView endUpdates];
    }
}

# pragma mark - Import From Contacts methods

- (IBAction)importFromContacts:(id)sender
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        // First time access
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"First time access to AddressBook has been granted");
                [self showAddressBookPickerController];
            } else {
                [self showNeedAddressBookAccessAlert];
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access
        [self showAddressBookPickerController];
    } else {
        // The user has previously denied access
        [self showNeedAddressBookAccessAlert];
    }
}

- (void)showAddressBookPickerController
{
    self.contacts = [[ABPeoplePickerNavigationController alloc] init];
    [self.contacts setPeoplePickerDelegate:self];
    [self.contacts setDisplayedProperties:@[[NSNumber numberWithInt:kABPersonFirstNameProperty],
                                            [NSNumber numberWithInt:kABPersonLastNameProperty],
                                            [NSNumber numberWithInt:kABPersonEmailProperty],
                                            [NSNumber numberWithInt:kABPersonPhoneProperty],
                                            [NSNumber numberWithInt:kABPersonAddressProperty]]];
    [self presentViewController:self.contacts animated:YES completion:nil];
}

- (void)showNeedAddressBookAccessAlert
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [TSMessage showNotificationInViewController:self
                                          title:@"Authorization Required"
                                       subtitle:@"You need to grant access to your contacts.  You can do this by going to the Privacy Settings in the Settings app"
                                           type:TSMessageNotificationTypeWarning];
}

- (void)clearFields
{
    self.firstNameField.text = nil;
    self.lastNameField.text = nil;
    self.primaryPhoneField.text = nil;
    self.mobilePhoneField.text = nil;
    self.emailField.text = nil;
    self.streetAddressField.text = nil;
    self.cityField.text = nil;
    self.stateField.text = nil;
    self.zipcodeField.text = nil;
}

# pragma mark - ABPeoplePickerNavigationControllerDelegate

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
                             identifier:(ABMultiValueIdentifier)identifier
{
    [self clearFields];
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSArray *phones = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty));
    NSArray *emails = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty));
    NSArray *address = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonAddressProperty));
    
    self.firstNameField.text = firstName;
    self.lastNameField.text = lastName;
    if ([phones count] > 0) {
        self.primaryPhoneField.text = phones[0];
    }
    if ([phones count] >= 2) {
        self.mobilePhoneField.text = phones[1];
    }
    if ([emails count] > 0) {
        self.emailField.text = emails[0];
    }
    if ([address count] > 0) {
        NSDictionary *addressDict = address[0];
        self.streetAddressField.text = addressDict[@"Street"];
        self.cityField.text = addressDict[@"City"];
        self.stateField.text = addressDict[@"State"];
        self.zipcodeField.text = addressDict[@"ZIP"];
    }
    
    [self.contacts dismissViewControllerAnimated:YES completion:nil];
    
	return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self.contacts dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Choose Image methods

- (IBAction)showPictureOptions:(id)sender
{
    UIActionSheet *pictureOptionsActionSheet = [[UIActionSheet alloc] init];
    pictureOptionsActionSheet.delegate = self;

    if (self.person.thumbnail) {
        [pictureOptionsActionSheet setDestructiveButtonIndex:[pictureOptionsActionSheet addButtonWithTitle:@"Delete"]];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsActionSheet addButtonWithTitle:@"Take Photo"];
    }
    
    [pictureOptionsActionSheet addButtonWithTitle:@"Choose Photo"];
    [pictureOptionsActionSheet addButtonWithTitle:@"Cancel"];
    pictureOptionsActionSheet.cancelButtonIndex = pictureOptionsActionSheet.numberOfButtons - 1;
 
    [pictureOptionsActionSheet showInView:self.view];
    
    // Move to top
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Delete"]) {
        DDLogVerbose(@"Should Delete Photo");
        NSAssert(self.person.thumbnail, @"To delete we need a thumbnail");
        [self deleteThumbnail];
    } else if ([buttonTitle isEqualToString:@"Take Photo"]) {
        DDLogVerbose(@"Should take photo");
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if ([buttonTitle isEqualToString:@"Choose Photo"]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.hasThumbnailChanged = YES;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSData *data = [Common thumbnailDataForImage:image width:kLDSImageWidth heigth:kLDSImageHeight cornerRadius:kLDSImageRadius];
    
    [self.thumbnailImageView setImage:[UIImage imageWithData:data]];
    self.backgroundImage.image = [[UIImage imageWithData:data] applyLightEffect];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteThumbnail
{
    DDLogVerbose(@"Should Delete Photo");
    self.hasThumbnailChanged = YES;
    self.thumbnailImageView.image = nil;
}

# pragma mark - Next Text Fields helper methods

- (void)setupNextTextFields
{
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.primaryPhoneField.delegate = self;
    self.mobilePhoneField.delegate = self;
    self.emailField.delegate = self;
    self.streetAddressField.delegate = self;
    self.cityField.delegate = self;
    self.stateField.delegate = self;
    self.zipcodeField.delegate = self;
    
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.nextTextField = self.primaryPhoneField;
    self.primaryPhoneField.nextTextField = self.mobilePhoneField;
    self.mobilePhoneField.nextTextField = self.emailField;
    self.emailField.nextTextField = self.streetAddressField;
    self.streetAddressField.nextTextField = self.cityField;
    self.cityField.nextTextField = self.stateField;
    self.stateField.nextTextField = self.zipcodeField;
    self.zipcodeField.nextTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *next = textField.nextTextField;
    
    if (next) {
        [next becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

# pragma mark PickerView Protocol
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.organizations count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.organizations objectAtIndex:row] name];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedOrganization = [self.organizations objectAtIndex:row];
    [self.organizationButton setTitle:self.selectedOrganization.name forState:UIControlStateNormal];
}

# pragma mark - inline UIPickerView: table methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        return self.organizationCellHeight;
    } else if (self.person && indexPath.section == 0 && indexPath.row == 1) {
        DDLogVerbose(@"Setting height to 0");
        return 0;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01f;
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

@end

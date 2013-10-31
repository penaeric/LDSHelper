//
//  BatchImportTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 7/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "BatchImportTVC.h"
#import "Organization.h"
#import "ContactsToImportTVC.h"
#import "TSMessage.h"

@interface BatchImportTVC () <ContactsToImportDelegate, SWRevealViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;
@property (weak, nonatomic) IBOutlet UISwitch *skipDuplicatesSwitch;

@property (nonatomic, strong) NSArray *organizations;
@property (strong, nonatomic) Organization *selectedOrganization;

@property (assign, nonatomic) CGFloat organizationCellHeight;
@property (assign, nonatomic) BOOL isPickerSelected;
@property (weak, nonatomic) IBOutlet UITableViewCell *organizationCell;

@end

@implementation BatchImportTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.revealViewController.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self setupView];
}

-(void) setupView
{
    self.isPickerSelected = NO;
    self.organizationCellHeight = 44.0;
    [self.tableView setAllowsSelection:YES];
    [self loadOrganizations];
    
    self.selectedOrganization = [[Config sharedConfig] currentOrganization];
    self.organizationLabel.text = self.selectedOrganization.name;
}

- (void)loadOrganizations
{
    if (!self.organizations) {
        self.organizations = [Organization findAllSortedBy:@"name" ascending:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Import Contacts"]) {
        ContactsToImportTVC *contactsTVC = segue.destinationViewController;
        contactsTVC.delegate = self;
        contactsTVC.skipDuplicates = self.skipDuplicatesSwitch.on;
        contactsTVC.organization = self.selectedOrganization;
    }
}

- (IBAction)switchedSkipDuplicates:(id)sender
{
    [self.tableView reloadData];
}

- (void)contactsWereImported:(ContactsToImportTVC *)controller imported:(NSInteger)imported skipped:(NSInteger)skipped
{
    [controller.navigationController popToRootViewControllerAnimated:YES];
    
    NSString *message = [NSString stringWithFormat:@"Imported: %d\nSkipped: %d",
                                imported,
                                skipped];
    
    [TSMessage showNotificationInViewController:self
                                          title:@"Contacts Imported"
                                       subtitle:message
                                           type:TSMessageNotificationTypeSuccess];
}

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
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
    self.organizationLabel.text = self.selectedOrganization.name;
}

# pragma mark - inline UIPickerView: table methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.organizationCellHeight;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.organizationCell && self.isPickerSelected == NO) {
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
                             self.organizationLabel.alpha = 0;
                         } completion:nil];
    }

}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.organizationCell) {
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
                             self.organizationLabel.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             [organizationPicker removeFromSuperview];
                         }];
        [self.tableView beginUpdates];
        self.organizationCellHeight = 44.;
        [self.tableView endUpdates];
    }
    
    return indexPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        if (self.skipDuplicatesSwitch.on) {
            return @"Will skip people with the same name.";
        }
        return @"Will replace people when names are equal.";
    }
    
    return [super tableView:tableView titleForFooterInSection:section];
}

#pragma mark - SWRevealViewControllerDelegate

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        UIView *lockingView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
        [lockingView addGestureRecognizer:tap];
        [lockingView setTag:1000];
        [revealController.frontViewController.view addSubview:lockingView];
    } else {
        [[revealController.frontViewController.view viewWithTag:1000] removeFromSuperview];
    }
}

@end

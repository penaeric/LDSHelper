//
//  MemberDetailTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 6/22/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MemberDetailTVC.h"
#import "MemberEditTVC.h"
#import "Organization.h"
#import "UIImage+ImageEffects.h"
#import "GenericCellWithButton.h"

@interface MemberDetailTVC () <UIActionSheetDelegate, EditMemberDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fullImage;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *primaryPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *bigFullLabel;

@property (strong, nonatomic) NSMutableArray *hiddenSections;
@property (strong, nonatomic) NSString *cityStateZip;

@end

@implementation MemberDetailTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericCellWithButton" bundle:nil] forCellReuseIdentifier:@"Delete Cell"];
    
    [self hiddeSections];
    [self setupView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit Member"]) {
        MemberEditTVC *editTVC = segue.destinationViewController;
        editTVC.person = self.person;
        editTVC.delegate = self;
    }
}

# pragma mark - Delete Member ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Delete"]) {
        NSLog(@"Deleting person");
        [[NSManagedObjectContext defaultContext] deleteObject:self.person];
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteMember:(id)sender
{
    UIActionSheet *deleteMemberActionSheet = [[UIActionSheet alloc]
                                              initWithTitle:nil
                                              delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Delete"
                                              otherButtonTitles:nil];
    
    [deleteMemberActionSheet showInView:self.view];
}

# pragma mark - EditMemberDelegate

- (void)updatedPerson:(Person *)person
{
    self.person = person;
}

# pragma mark - Helper methods

- (void)setupView
{
    NSAssert(self.person, @"Person expected");
    
    // Populate Form Fields
    self.fullnameLabel.text = [NSString stringWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
    self.bigFullLabel.text = self.fullnameLabel.text;
    self.organizationLabel.text = self.person.memberOf.name;
    self.primaryPhoneLabel.text = self.person.primaryPhone;
    self.mobilePhoneLabel.text = self.person.mobilePhone;
    self.emailLabel.text = self.person.email;
    self.streetAddressLabel.text = self.person.streetAddress;
    self.cityStateZipLabel.text = self.person.cityStateZipAddress;
    if (self.person.thumbnail) {
        self.fullImage.image = [[UIImage imageWithData:self.person.thumbnail] applyLightEffect];
    } else {
        NSString *imageName = [NSString stringWithFormat:@"default_member_background_%@", CurrentOrganization_Str[kLDSEldersQuorum]];
        self.fullImage.image = [[UIImage imageNamed:imageName] applyLightEffect];
    }
    if (self.person.thumbnail) {
        [self.thumbnailImageView setImage:[UIImage imageWithData:self.person.thumbnail]];
    } else {
        self.thumbnailImageView.image = [UIImage imageNamed:@"thumbnail_no_contact_placeholder"];
    }
    
    self.thumbnailImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailImageView.layer.borderWidth = 1.5;
    self.thumbnailImageView.layer.cornerRadius = 5;
}

- (void)hiddeSections
{
    self.hiddenSections = [NSMutableArray new];
    
    if ([self.person.primaryPhone length] == 0 && [self.person.mobilePhone length] == 0 && [self.person.email length] == 0) {
        [self.hiddenSections addObject:[NSNumber numberWithInt:2]];
    }
    if ([self.person.streetAddress length] == 0 && [self.person.cityStateZipAddress length] == 0) {
        [self.hiddenSections addObject:[NSNumber numberWithInt:3]];
    }

    [self.tableView reloadData];
}

# pragma mark - TableView Delegate methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.hiddenSections containsObject:[NSNumber numberWithInt:section]]) {
        return nil;
    }
    
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.hiddenSections containsObject:[NSNumber numberWithInt:indexPath.section]]) {
        return 0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:[self offsetIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.hiddenSections containsObject:[NSNumber numberWithInt:indexPath.section]]) {
        [cell setHidden:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    
    if (section == 0) {
        height = 0.01f;
    } else if ([self.hiddenSections containsObject:[NSNumber numberWithInt:section]]) {
        height = 0.01f; // Can't be zero
    } else if ([self tableView:tableView titleForHeaderInSection:section] == nil) {
        // Adjust height for previos hidden sections
        CGFloat adjust = 0;
        
        for (int i = (section - 1); i >= 0; i--) {
            if ([self.hiddenSections containsObject:[NSNumber numberWithInt:i]]) {
                adjust = adjust + 2;
            } else {
                break;
            }
        }
        
        if (adjust > 0) {
            if (height == -1) {
                height = self.tableView.sectionFooterHeight;
            }
            
            height = height - adjust;
            
            if (height < 1) {
                height = 1;
            }
        }
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [super tableView:tableView numberOfRowsInSection:section];
    
    if (section == 2) {
        if ([self.person.primaryPhone length] == 0) {
            rows--;
        }
        if ([self.person.mobilePhone length] == 0) {
            rows--;
        }
        if ([self.person.email length] == 0) {
            rows --;
        }
    } else if (section == 3) {
        if ([self.person.streetAddress length] == 0) {
            rows --;
        }
        if ([self.person.cityStateZipAddress length] == 0) {
            rows --;
        }
    } else if (section == 4) {
        return 1;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        GenericCellWithButton *cell = [tableView dequeueReusableCellWithIdentifier:@"Delete Cell" forIndexPath:indexPath];
        [cell.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cell.deleteButton addTarget:self action:@selector(deleteMember:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:[self offsetIndexPath:indexPath]];
}

- (NSIndexPath *)offsetIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0 && [self.person.primaryPhone length] == 0 && [self.person.mobilePhone length] > 0) {
            row++;
        } else if (indexPath.row == 0 && [self.person.primaryPhone length] == 0 && [self.person.email length] > 0) {
            row = row + 2;
        } else if (indexPath.row == 1 && [self.person.primaryPhone length] > 0  && [self.person.mobilePhone length] == 0) {
            row++;
        } else if (indexPath.row == 1 && [self.person.primaryPhone length] == 0  && [self.person.mobilePhone length] > 0) {
            row++;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0 && [self.person.streetAddress length] == 0) {
            row++;
        }
    }
    
    NSIndexPath *offsetPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
    
    return offsetPath;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

@end

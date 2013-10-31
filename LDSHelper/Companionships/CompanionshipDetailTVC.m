//
//  CompanionshipDetailTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/4/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "CompanionshipDetailTVC.h"
#import "Person+AddOns.h"
#import "CompanionshipEditTVC.h"
#import "GenericMemberCell.h"
#import "GenericCellWithButton.h"
#import "UIColor+LDSColors.h"

@interface CompanionshipDetailTVC () <UIActionSheetDelegate, EditCompanionshipDelegate> {
    // Maximum number of visits allowed. If this number needs to change, it also needs to be changed in the Data Model and in the Storyboard
    NSInteger MAX_VISITS;
}

@end


@implementation CompanionshipDetailTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericMemberCell" bundle:nil] forCellReuseIdentifier:@"Companion Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericCellWithButton" bundle:nil] forCellReuseIdentifier:@"Delete Cell"];
    
    MAX_VISITS = 10;
}


- (void)showDeleteActionSheet
{
    UIActionSheet *deleteCompanionshipActionSheet = [[UIActionSheet alloc]
                                                     initWithTitle:nil
                                                     delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:@"Delete"
                                                     otherButtonTitles:nil];
    
    [deleteCompanionshipActionSheet showInView:self.view];
}


- (IBAction)editCompanionship:(id)sender
{
    CompanionshipEditTVC *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Edit Companionship"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    tableViewController.delegate = self;
    tableViewController.companionship = self.companionship;
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark - CompanionshipDetail delegate

- (void)updatedCompanionship:(CompanionshipEditTVC *)controller
{
    DDLogVerbose(@"CompanionshipDetailTVC::updatedCompanionship");
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)editingWasCancelled:(CompanionshipEditTVC *)controller
{
    DDLogVerbose(@"CompanionshipDetailTVC::editingWasCancelled");
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate Delete Companionship

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Delete"]) {
        NSLog(@"Deleting Companionship");
        [[NSManagedObjectContext defaultContext] deleteObject:self.companionship];
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
        [self.delegate deletedCompanionship:self];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return MIN([self.companionship.visits count], MAX_VISITS);
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self companionCellForRowAtIndexPath:indexPath];
        
    } else if (indexPath.section == 1) {
        return [self memberCellForRowAtIndexPath:indexPath];
        
    } else if (indexPath.section == 2) {
        return [self deleteCellForRowAtIndexPath:indexPath];
        
    } else {
        DDLogError(@"Bad Index path: %@", indexPath);
        NSAssert(false, @"Invalid section");
    }
    
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
//        case 0:
//            return @"Companionship";
//            break;
            
        case 1:
            return @"Visit";
            break;
            
        default:
            return nil;
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}


# pragma mark - Table View Helper methods

- (UITableViewCell *)companionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Companion Cell";
    
    GenericMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor LDSLightGrayColor];
    
    if (indexPath.row == 0) {
        Person *person = [self.companionship.companions objectAtIndex:indexPath.row];
        cell.nameLabel.text = person.fullName;
        if (person.thumbnailSmall) {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        } else {
            cell.initialsLabel.text = person.initials;
        }
    } else if ([self.companionship.companions count] > 1) {
        Person *person = [self.companionship.companions objectAtIndex:indexPath.row];
        cell.nameLabel.text = person.fullName;
        if (person.thumbnailSmall) {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        } else {
            cell.initialsLabel.text = person.initials;
        }
    } else {
        cell.bottomImage.image = nil;
        cell.initialsLabel.text = @"";
        cell.thumbnailImage.image = nil;
        cell.nameLabel.text = @"";
    }
    
    return cell;
}


- (UITableViewCell *)memberCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Companion Cell";
    
    GenericMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Person *person = [self.companionship.visits objectAtIndex:indexPath.row];
    cell.nameLabel.text = person.fullName;
    if (person.thumbnailSmall) {
        cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
    } else {
        cell.initialsLabel.text = person.initials;
    }
    
    return cell;
}


- (UITableViewCell *)deleteCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Delete Cell";
    
    GenericCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cell.deleteButton addTarget:self action:@selector(showDeleteActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    
    return cell;
}

@end

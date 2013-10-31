//
//  CompanionshipEditTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/5/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "CompanionshipEditTVC.h"
#import "Companionship+WithGeneratedSortingName.h"
#import "Person.h"
#import "MemberChooserTVC.h"
#import "TSMessage.h"
#import "GenericMemberCell.h"
#import "GenericCellWithButton.h"
#import "UIColor+LDSColors.h"

@interface CompanionshipEditTVC () <MemberChooserDelegate> {
    BOOL newCompanionship;
}

@end

@implementation CompanionshipEditTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];

    [self setupView];
}

- (void)setupView
{
    DDLogVerbose(@"CompanionshipEdit::Companionship: {%@}", self.companionship.sortingName);
    newCompanionship = NO;
    
    if (!self.companionship) {
        DDLogInfo(@"+ + + It is new companionship, will create a new entity");
        newCompanionship = YES;
        self.companionship = [Companionship createEntity];
        self.companionship.inOrganization = [NSSet setWithObject:[[Config sharedConfig] currentOrganization]];
    }
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancel)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(save)];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.title = @"Companionship";
    
    // Register Cells for reuse
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericMemberCell" bundle:nil] forCellReuseIdentifier:@"Companion Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericCellWithButton" bundle:nil] forCellReuseIdentifier:@"New Visited Cell"];
}

- (void)showNewMemberChooser
{
    // Mimic selecting row to easily position new Visit (positionVisit:)
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    [self showMemberChooser:NO];
}

- (void)showMemberChooser
{
    [self showMemberChooser:NO];
}

- (void)showCompanionChooser
{
    [self showMemberChooser:YES];
}

- (void)showMemberChooser:(BOOL)isCompanionChooser
{
    MemberChooserTVC *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Member Chooser"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    tableViewController.delegate = self;
    tableViewController.isCompanionChooser = isCompanionChooser;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark = MemberChooser Delegate

- (void)choosePerson:(MemberChooserTVC *)controller
{
    if (controller.personChosen) {
        if (controller.isCompanionChooser) {
            [self positionCompanion:controller.personChosen];
        } else {
            [self positionVisit:controller.personChosen];
        }
        
        [self.tableView reloadData];
        
    } else {
        DDLogInfo(@"Nothing to do. No Person choosen");
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

// Position the new Visit in the right bucket
- (void)positionVisit:(Person *)person
{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    NSMutableOrderedSet *visits;
    
    if (selectedRowIndexPath.section == 2) {
        // Adding new Visit
        visits = [NSMutableOrderedSet orderedSetWithOrderedSet:self.companionship.visits];
        [visits addObject:person];
    } else {
        // Remplacing a Visit
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.companionship.visits array]];
        array[selectedRowIndexPath.row] = person;
        visits = [NSMutableOrderedSet orderedSetWithArray:array];
    }
    
    self.companionship.visits = visits;
}

// Position the new Companion in the right bucket
- (void)positionCompanion:(Person *)companion
{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    NSInteger index = MIN(selectedRowIndexPath.row, [self.companionship.companions count]);
    NSMutableOrderedSet *companions;
    NSInteger count = [self.companionship.companions count];
    DDLogVerbose(@"+ + + Count: %i  Index: %i", count, index);
    
    switch (count) {
        case 0:
            DDLogVerbose(@"+ + + 00 Inserting at [0] with empty Set");
            companions = [NSMutableOrderedSet orderedSetWithObject:companion];
            break;
        case 1:
            if (index == 0) {
                // Remplace with empty set
                DDLogVerbose(@"+ + + 01 Remplacing at [0] with empty Set");
                companions = [NSMutableOrderedSet orderedSetWithObject:companion];
            } else {
                // Add at [1]
                DDLogVerbose(@"+ + + 02 Inserting at [1], with old at [1]");
                companions = [NSMutableOrderedSet orderedSetWithArray:@[[self.companionship.companions objectAtIndex:0], companion]];
            }
            break;
        case 2:
            if (index == 0) {
                // Remplace with empty set
                DDLogVerbose(@"+ + + 01 Remplacing at [0] with old at [0]");
                companions = [NSMutableOrderedSet orderedSetWithArray:@[companion, [self.companionship.companions objectAtIndex:1]]];
            } else {
                // Add at [1]
                DDLogVerbose(@"+ + + 02 Inserting at [1], with old at [1]");
                companions = [NSMutableOrderedSet orderedSetWithArray:@[[self.companionship.companions objectAtIndex:0], companion]];
            }
            break;
            
        default:
            NSAssert(true, @"Companionship should never have more than 2 companions");
            break;
    }
    
    self.companionship.companions = companions;
}

#pragma mark - Navigation

- (void)cancel
{
    if (newCompanionship) {
        // It was a new Companionship, delete it!
        DDLogVerbose(@" + + + It was new companionship, trying to delete: {%@}", self.companionship);
        [[NSManagedObjectContext defaultContext] deleteObject:self.companionship];
    } else {
        [[NSManagedObjectContext defaultContext] refreshObject:self.companionship mergeChanges:NO];
    }
    
    [self.delegate editingWasCancelled:self];
}

- (void)save
{
    if ([self.companionship.companions count] == 0) {
        [TSMessage showNotificationInViewController:self
                                              title:@"No Companionship"
                                           subtitle:@"You need to select at least one member to be a Companion"
                                               type:TSMessageNotificationTypeWarning];
        
    } else {
        self.companionship.sortingName = @"";
        [[NSManagedObjectContext defaultContext] saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogVerbose(@"Companionship saved successfully");
            } else {
                DDLogError(@"Could not save comopanionship: {%@}", [error localizedDescription]);
#ifdef DEBUG
                NSAssert(true, [error localizedDescription]);
#endif
            }
        }];
        if (newCompanionship) {
            [self.delegate aNewCompanionshipWasCreated:self];
        } else {
            [self.delegate updatedCompanionship:self];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.companionship.visits count] < 10) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return [self.companionship.visits count];
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    switch (indexPath.section) {
        case 0:
            CellIdentifier = @"Companion Cell";
            break;
        case 1:
            CellIdentifier = @"Companion Cell";//@"Visited Cell";
            break;
        case 2:
            CellIdentifier = @"New Visited Cell";
            break;
        default:
            break;
    }
    
    if (indexPath.section == 0) {
        GenericMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        // Companions
        if (indexPath.row + 1 <= [self.companionship.companions count]) {
            Person *person = [self.companionship.companions objectAtIndex:indexPath.row];
            cell.nameLabel.text = person.fullName;
            cell.backgroundColor = [UIColor LDSLightGrayColor];
            if (person.thumbnailSmall) {
                cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
                cell.initialsLabel.text = @"";
            } else {
                cell.thumbnailImage.image = nil;
                cell.initialsLabel.text = person.initials;
            }
        } else {
            cell.nameLabel.text = @"";
            cell.thumbnailImage.image = nil;
            cell.initialsLabel.text = @"";
        }
        
        return cell;
        
    } else if (indexPath.section == 1) {
        GenericMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        // Visits
        Person *person = [self.companionship.visits objectAtIndex:indexPath.row];
        cell.nameLabel.text = person.fullName;
        if (person.thumbnailSmall) {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
            cell.initialsLabel.text = @"";
        } else {
            cell.thumbnailImage.image = nil;
            cell.initialsLabel.text = person.initials;
        }
        
        return cell;
    } else {
        GenericCellWithButton *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.deleteButton setTitle:@"Add" forState:UIControlStateNormal];
        [cell.deleteButton addTarget:self action:@selector(showNewMemberChooser) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DDLogInfo(@"Time to choose a new companion");
        [self showCompanionChooser];

    } else if (indexPath.section == 1) {
        DDLogInfo(@"Time to choose a member to be visited");
        [self showMemberChooser];
    }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DDLogVerbose(@"row + 1 >> {%i} {%i} << companions", (indexPath.row + 1), [self.companionship.companions count]);
        return indexPath.row + 1 <= [self.companionship.companions count];
    }
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            // Delete Companions
            NSInteger count = [self.companionship.companions count];
            if (count == 1) {
                DDLogVerbose(@"+ + + Deleting all companions");
                self.companionship.companions = [NSOrderedSet orderedSet];
            } else if (indexPath.row == 0) {
                DDLogVerbose(@"+ + + Deleting first companion");
                self.companionship.companions = [NSOrderedSet orderedSetWithObject:[self.companionship.companions objectAtIndex:1]];
            } else {
                DDLogVerbose(@"+ + + Deleting second companion");
                self.companionship.companions = [NSOrderedSet orderedSetWithObject:[self.companionship.companions objectAtIndex:0]];
            }
        } else if (indexPath.section == 1) {
            // Delete Visits
            NSIndexSet *indexSet = [self.companionship.visits indexesOfObjectsPassingTest:
                                    ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                        return idx != indexPath.row;
                                    }];
            self.companionship.visits = [NSOrderedSet orderedSetWithArray:[self.companionship.visits objectsAtIndexes:indexSet]];
        }
    }
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return 44.0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
    return 20.0;
}

@end

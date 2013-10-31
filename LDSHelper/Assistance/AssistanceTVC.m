//
//  AssistanceTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "AssistanceTVC.h"
#import "Person+AddOns.h"
#import "Organization.h"
#import "Assistance+FirstDayOfMonth.h"
#import "MZDayPicker.h"
#import "GenericMemberCell.h"

@interface AssistanceTVC () {
    BOOL assistanceWasChanged;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *indexArray;
@property (strong, nonatomic) Assistance *assistance;
@property (weak, nonatomic) Organization *organization;

@end

@implementation AssistanceTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericMemberCell" bundle:nil]
         forCellReuseIdentifier:@"Member Cell"];
    
    [self setupFetchedResultsController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([[NSManagedObjectContext defaultContext] hasChanges]) {
        [[NSManagedObjectContext defaultContext] saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"00:Assistance saved!");
            } else {
                NSLog(@"00:Assistance NOT saved: %@", [error localizedDescription]);
            }
        }];
    }
}

- (void)setupView
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    assistanceWasChanged = NO;
    self.indexArray = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",@"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    [self setCurrentAssistance];
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if (assistanceWasChanged) {
        [[NSManagedObjectContext defaultContext] saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"> > > 01:Assistance saved");
            } else {
                NSLog(@"> > > 01:Assistance not saved: %@", [error localizedDescription]);
            }
        }];
    }
    
    assistanceWasChanged = NO;
    _currentDate = currentDate;
    [self setCurrentAssistance];
}

- (Organization *) organization {
    return [[Config sharedConfig] currentOrganization];
}

- (void)setCurrentAssistance
{
    BOOL hadAssistance = (self.assistance != nil);
    if (!self.currentDate) {
        // Hack for currentDate
        self.currentDate = [NSDate dateWithNoTime:[NSDate date] middleDay:YES];
        self.currentDate = [self.currentDate dateByAddingTimeInterval:-60.0 * 60.0 * 24.0];
    }
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"date = %@ AND organization.name = %@",
                              self.currentDate,
                              self.organization.name];
    
    self.assistance = [Assistance findFirstWithPredicate:predicate];
    
    if (hadAssistance || self.assistance) {
        [self.tableView reloadData];
    }
}

#pragma mark - Navigation

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
}

#pragma mark - Table view data source

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"memberOf.name = %@", [[Config sharedConfig] currentOrganization].name];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"normalizedName"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:[NSManagedObjectContext defaultContext]
                                     sectionNameKeyPath:@"initial"
                                     cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Member Cell";
    
    GenericMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = person.fullName;
    
    if (!person.thumbnailSmall) {
        cell.initialsLabel.text = person.initials;
    }
    
    if ([self.assistance.persons containsObject:person]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.nameLabel.textColor = [Config colorForOrganization:self.organization.name];
        cell.initialsLabel.textColor = [Config colorForOrganization:self.organization.name];
        if (person.thumbnailSmall) {
            cell.initialsLabel.text = @"";
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        } else {
            cell.thumbnailImage.image = nil;
        }
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.nameLabel.textColor = [UIColor darkGrayColor];
        cell.initialsLabel.textColor = [UIColor darkGrayColor];
        if (person.thumbnailGraySmall) {
            cell.initialsLabel.text = @"";
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailGraySmall];
        } else {
            cell.thumbnailImage.image = nil;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSString *letter = [self.indexArray objectAtIndex:index];
    NSUInteger sectionIndex = [[self.fetchedResultsController sectionIndexTitles] indexOfObject:letter];
    while (sectionIndex > [self.indexArray count]) {
        if (index <= 0) {
            sectionIndex = 0;
            break;
        }
        sectionIndex = [self tableView:tableView sectionForSectionIndexTitle:title atIndex:index - 1];
    }
    
    return sectionIndex;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GenericMemberCell *cell = (GenericMemberCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    assistanceWasChanged = YES;
    
    if (!self.assistance) {
        self.assistance = [Assistance createEntity];
        self.assistance.date = self.currentDate;
        self.assistance.organization = self.organization;
    }
    
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DDLogVerbose(@"Selected Person: {%@}", person.fullName);
    NSMutableSet *persons = [[NSMutableSet alloc] initWithSet:self.assistance.persons];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        DDLogVerbose(@"Removing person!!!");
        [persons removeObject:person];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.nameLabel.textColor = [UIColor darkGrayColor];
        cell.initialsLabel.textColor = [UIColor darkGrayColor];
        if (person.thumbnailGraySmall) {
            cell.initialsLabel.text = @"";
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailGraySmall];
        } else {
            cell.thumbnailImage.image = nil;
        }
    } else {
        DDLogVerbose(@"Adding person!!!");
        [persons addObject:person];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.nameLabel.textColor = [Config colorForOrganization:self.organization.name];
        cell.initialsLabel.textColor = [Config colorForOrganization:self.organization.name];
        if (person.thumbnailSmall) {
            cell.initialsLabel.text = @"";
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        } else {
            cell.thumbnailImage.image = nil;
        }
    }
    
    self.assistance.persons = persons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLDSHeightForGenericMemberCell;
}

@end

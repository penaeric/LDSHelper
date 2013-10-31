//
//  CompanionshipsTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "CompanionshipsTVC.h"
#import "Companionship.h"
#import "CompanionshipDetailTVC.h"
#import "CompanionshipEditTVC.h"
#import "CompanionshipCell.h"
#import "Person+AddOns.h"
#import "Organization.h"
#import "UIColor+LDSColors.h"

@interface CompanionshipsTVC () <EditCompanionshipDelegate, CompanionshipDetailDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) Organization *currentOrganization;

@end

@implementation CompanionshipsTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.revealViewController.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self setupView];
    
    [self setupFetchedResultsController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
}

- (void)setupView
{
    if (!self.currentOrganization) {
        self.currentOrganization = [[Config sharedConfig] currentOrganization];
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

#pragma mark - Navigation

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
}

- (IBAction)addCompanionship:(id)sender
{
    CompanionshipEditTVC *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Edit Companionship"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    tableViewController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Companionship Detail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Companionship *companionship = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        CompanionshipDetailTVC *tvc = segue.destinationViewController;
        tvc.companionship = companionship;
        tvc.delegate = self;
    } else {
        NSAssert(false, @"Unidentified Segue Attempted");
    }
}

#pragma mark - CompanionshipDetailDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)deletedCompanionship:(CompanionshipDetailTVC *)controller
{
    DDLogVerbose(@"HomeTeachingEQTVC::deletedCompanionship");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - EditCompanionshipDelegate

- (void)aNewCompanionshipWasCreated:(CompanionshipEditTVC *)controller
{
    DDLogVerbose(@"HomeTeachingEQTVC::aNewCompanionshipWasCreated");
    [controller dismissViewControllerAnimated:YES completion:^{
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:controller.companionship];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }];
}

#warning Fix problem when canceling! (I believe Core Data is not undoing all the relationships with this Companionship, try undoing them manually
- (void)editingWasCancelled:(CompanionshipEditTVC *)controller
{
    DDLogVerbose(@"HomeTeachingEQTVC::editingWasCancelled");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Companionship"];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY inOrganization.name = %@", self.currentOrganization.name];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortingName"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:[NSManagedObjectContext defaultContext]
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
}

- (void)setupCell:(CompanionshipCell *)cell withCompanionship:(Companionship *)companionship cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSOrderedSet *companions = companionship.companions;
    
    if ([companions count] > 0) {
        Person *person = companions[0];
        cell.nameLabelLeft.text = person.fullName;
        if (person.thumbnailSmall) {
            cell.thumbnailImageLeft.image = [UIImage imageWithData:person.thumbnailSmall];
            cell.initialsLabelLeft.text = @"";
        } else {
            cell.thumbnailImageLeft.image = nil;
            cell.initialsLabelLeft.text = person.initials;
        }
    }
    if ([companions count] > 1) {
        Person *person = companions[1];
        cell.nameLableRight.text = person.fullName;
        if (person.thumbnailSmall) {
            cell.thumbnailImageRight.image = [UIImage imageWithData:person.thumbnailSmall];
            cell.initialsLabelRight.text = @"";
        } else {
            cell.thumbnailImageRight.image = nil;
            cell.initialsLabelRight.text = person.initials;
            cell.backgroundColor = [UIColor LDSLightGrayColor];
        }
    }
    
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor LDSLightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Companionship Cell";
    CompanionshipCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Companionship *companionship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self setupCell:cell withCompanionship:companionship cellForRowAtIndexPath:indexPath];
    
    return cell;
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

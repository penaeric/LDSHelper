//
//  MembersTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MembersTVC.h"
#import "MemberCell.h"
#import "Person+AddOns.h"
#import "MemberDetailTVC.h"
#import "MemberEditTVC.h"
#import "UIColor+LDSColors.h"

@interface MembersTVC () <EditMemberDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *indexArray;

@end

@implementation MembersTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
    
//    ddLogLevel = LOG_LEVEL_VERBOSE;
    [self setupFetchedResultsController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.revealViewController.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.indexArray = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",@"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

#pragma mark - Navigation

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
}

- (IBAction)addMember:(id)sender
{
    MemberEditTVC *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editMember"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    tableViewController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"See Member"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"Person to see: %@", person.fullName);
        
        MemberDetailTVC *tvc = segue.destinationViewController;
        tvc.person = person;
    } else {
        NSAssert(false, @"Unidentified Segue Attempted");
    }
}

- (void)aNewMemberWasCreated:(MemberEditTVC *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:controller.person];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }];
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
    static NSString *CellIdentifier = @"Cell";
    
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.thumbnail.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.thumbnail.layer.borderWidth = 1.5;
    cell.thumbnail.layer.cornerRadius = 5;
    
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = person.fullName;
    cell.phoneLabel.text = person.primaryPhone;
    cell.emailLabel.text = person.email;
    if (person.thumbnailSmall) {
        cell.thumbnail.image = [UIImage imageWithData:person.thumbnailSmall];
        cell.initialsLabel.text = @"";
    } else {
        cell.initialsLabel.text = person.initials;
        cell.thumbnail.layer.backgroundColor = [UIColor LDSLightGrayColor].CGColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

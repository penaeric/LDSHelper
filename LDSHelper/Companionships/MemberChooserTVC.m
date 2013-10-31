//
//  MemberChooserTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/6/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MemberChooserTVC.h"
#import "Organization.h"
#import "GenericMemberCell.h"

@interface MemberChooserTVC ()

@property (weak, nonatomic) Organization *organization;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *indexArray;

@end

@implementation MemberChooserTVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericMemberCell" bundle:nil] forCellReuseIdentifier:@"Member Cell"];
    
    [self setupFetchedResultsController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.indexArray = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",@"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];

    [self setupView];
}

- (void)setupView
{
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    self.title = (self.isCompanionChooser) ? @"Companion" : @"Visit";
}

- (Organization *) organization {
    return [[Config sharedConfig] currentOrganization];
}

#pragma mark - Navigation

- (void)cancel:(id)sender
{
    self.personChosen = nil;
    [self.delegate choosePerson:self];
}

#pragma mark - Table view data source

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    
    if (self.isCompanionChooser) {
        request.predicate = [NSPredicate predicateWithFormat:@"memberOf.name = %@ AND companionedBy = %@", self.organization.name, nil];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"memberOf.name = %@ AND visitedBy = %@", self.organization.name, nil];
    }
    
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
    static NSString *cellIdentifier = @"Member Cell";
    GenericMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = person.fullName;
    if (person.thumbnailSmall) {
        cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        cell.initialsLabel.text = @"";
    } else {
        cell.thumbnailImage.image = nil;
        cell.initialsLabel.text = person.initials;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.personChosen = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate choosePerson:self];
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

@end

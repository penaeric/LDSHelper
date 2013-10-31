//
//  HomeTeachingTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/20/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "HomeTeachingTVC.h"
#import "Companionship.h"
#import "Visit.h"
#import "NSDate+Reporting.h"
#import "HomeTeachingReportEditTVC.h"
#import "HomeTeachingCell.h"
#import "Person+AddOns.h"
#import "UIColor+LDSColors.h"
#import "GenericMemberCell.h"
#import "Person+AddOns.h"
#import "TSMessage.h"
#import "Organization.h"

@interface HomeTeachingTVC () <HomeTeachingReportDelegate>

@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSFetchRequest *visitedCountRequest;
@property (weak, nonatomic) Organization *organization;

@end


@implementation HomeTeachingTVC

@synthesize currentDate = _currentDate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;

    [self setupView];
}


- (void)setCurrentDate:(NSDate *)currentDate
{
    _currentDate = currentDate;
    
    [self.tableView reloadData];
}


- (NSDate *)currentDate
{
    if (!_currentDate) {
        _currentDate = [NSDate firstDayOfMonth:[NSDate date]];
    }
    
    return _currentDate;
}


- (void)setIsCompanionshipView:(BOOL)isCompanionshipView
{
    _isCompanionshipView = isCompanionshipView;
    
    [self setupView];
}

- (Organization *)organization
{
    if (!_organization) {
        _organization = [[Config sharedConfig] currentOrganization];
    }
    
    return _organization;
}


- (void)setupView
{
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericMemberCell" bundle:nil]
         forCellReuseIdentifier:@"Member Cell"];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // By Companionship
    if (self.isCompanionshipView) {
        // VisitedCount request
        self.visitedCountRequest = [NSFetchRequest fetchRequestWithEntityName:@"Visit"];
        
        NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"visited"];
        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[keyExpression]];
        NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
        [description setName:@"visitedCount"];
        [description setExpression:countExpression];
        [description setExpressionResultType:NSInteger16AttributeType];
        
        self.visitedCountRequest.propertiesToFetch = @[description];
        self.visitedCountRequest.resultType = NSDictionaryResultType;
        
        // Visit request
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Companionship"];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY inOrganization = %@",
                                  [[Config sharedConfig] currentOrganization]];
        
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortingName"
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        self.dataArray = [[NSManagedObjectContext defaultContext] executeFetchRequest:fetchRequest error:nil];
    }
    // By Members
    else {
        // Members request
        self.dataArray = [Person findAllSortedBy:@"normalizedName" ascending:YES];
    }
    
    [self.tableView reloadData];
}


- (NSUInteger)getVisitedCountForCompanionship:(Companionship *)companionship
{
    self.visitedCountRequest.predicate = [NSPredicate predicateWithFormat:@"companionship = %@ AND date = %@",
                                          companionship, self.currentDate];
    
    NSArray *visitsVisitedCount = [[NSManagedObjectContext defaultContext] executeFetchRequest:self.visitedCountRequest error:nil];
    
    NSNumber *visitedCount = (NSNumber *)visitsVisitedCount[0][@"visitedCount"];
    
    return [visitedCount integerValue];
}


- (NSString *)notVisitedMessage
{
    NSMutableString *message = [NSMutableString stringWithString:@"This member is not being visited. You can go to Companionships to assing "];
    
    if ([CurrentOrganization_FullString[kLDSEldersQuorum] isEqualToString: self.organization.name]) {
        [message appendString:@"him Home Teachers."];
        
    } else if ([CurrentOrganization_FullString[kLDSReliefSociety] isEqualToString:self.organization.name]) {
        [message appendString:@"her Visiting Teachers."];
    }
    
    return message;
}


#pragma mark - HomeTeachingReportDelegate

- (void)updatedVisit:(HomeTeachingReportEditTVC *)controller
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)deletedVisit:(HomeTeachingReportEditTVC *)controller
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isCompanionshipView) {
        return 1;
    }
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isCompanionshipView) {
        return [self.dataArray count];
    }
    
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isCompanionshipView) {
        static NSString *CellIdentifier = @"Cell";
        
        HomeTeachingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Companionship *companionship = self.dataArray[indexPath.row];
        
        [self setupCompanionshipCell:cell withCompanionship:companionship];
        
        return cell;
        
    }
    
    // Member Cell
    static NSString *CellIdentifier = @"Member Cell";
    
    GenericMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Person *person = self.dataArray[indexPath.row];
    [self setupMemberCell:cell withPerson:person];
    
    return cell;
}


- (void)setupMemberCell:(GenericMemberCell *)cell withPerson:(Person *)person
{
    Visit *visit = [Visit findFirstWithPredicate:[NSPredicate predicateWithFormat:@"date = %@ AND companionship = %@",
                                                  self.currentDate, person.visitedBy]];
    
    cell.nameLabel.text = person.fullName;
    
    if (person.thumbnailSmall) {
        cell.initialsLabel.text = @"";
        if ([visit.visited containsObject:person]) {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        } else {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailGraySmall];
        }
        
    } else {
        cell.thumbnailImage.image = nil;
        cell.initialsLabel.text = person.initials;
        cell.thumbnailImage.layer.backgroundColor = [UIColor LDSLightGrayColor].CGColor;
    }
    
    if ([visit.visited containsObject:person]) {
        cell.nameLabel.textColor = [Config colorForCurrentOrganization];
        cell.initialsLabel.textColor = [Config colorForCurrentOrganization];
    } else {
        cell.nameLabel.textColor = [UIColor LDSDarkGrayColor];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTeachingReportEditTVC *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Home Teaching Report"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    
    Companionship *companionship;
    
    if (self.isCompanionshipView) {
        companionship = self.dataArray[indexPath.row];
        
    } else {
        Person *person = self.dataArray[indexPath.row];
        companionship = person.visitedBy;
        
        if (!companionship) {
            DDLogInfo(@"Is not visited by any one!!!");
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSString *message = [self notVisitedMessage];
            
            [TSMessage showNotificationInViewController:self.navigationController
                                                  title:@"Not being visited"
                                               subtitle:message
                                                   type:TSMessageNotificationTypeWarning];

            return;
        }
    }
    
    tableViewController.delegate = self;
    tableViewController.currentDate = self.currentDate;
    tableViewController.companionship = companionship;
    tableViewController.isCompanionshipView = self.isCompanionshipView;
    
    [TSMessage dismissActiveNotification];
    
    [self presentViewController:navController animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isCompanionshipView) {
        return 100;
    }
    
    return kLDSHeightForGenericMemberCell;
}


- (void)setupCompanionshipCell:(HomeTeachingCell *)cell withCompanionship:(Companionship *)companionship
{
    NSUInteger visitedCount = [self getVisitedCountForCompanionship:companionship];
    NSUInteger visitCount = [companionship.visits count];
    NSOrderedSet *companions = companionship.companions;
    
    // First Companion
    Person *person = companions[0];
    cell.topNameLabel.text = person.fullName;
    if (person.thumbnailSmall) {
        cell.thumbnailImageLeft.image = [UIImage imageWithData:person.thumbnailSmall];
        cell.initialsLabelLeft.text = @"";
    } else {
        cell.thumbnailImageLeft.image = nil;
        cell.initialsLabelLeft.text = person.initials;
    }
    
    // Second companion
    if ([companions count] > 1) {
        person = companions[1];
        cell.bottomNameLabel.text = person.fullName;
        
        if (person.thumbnailSmall) {
            cell.thumbnailImageLeft.image = [UIImage imageWithData:person.thumbnailSmall];
            cell.initialsLabelLeft.text = @"";
        } else {
            cell.thumbnailImageLeft.image = nil;
            cell.initialsLabelLeft.text = person.initials;
        }
    }
    
    // Visit/Visited
    cell.visitLabel.text = [NSString stringWithFormat:@"Visit: %i", visitCount];
    cell.visitedLabel.text = [NSString stringWithFormat:@"Visited: %i", visitedCount];
    if (visitCount > 0 && visitCount == visitedCount) {
        cell.visitedLabel.layer.backgroundColor = [UIColor LDSGreenColor].CGColor;
        cell.visitedLabel.textColor = [UIColor whiteColor];
    } else if (visitCount > 0 && visitedCount == 0) {
        cell.visitedLabel.layer.backgroundColor = [UIColor LDSRedColor].CGColor;
        cell.visitedLabel.textColor = [UIColor whiteColor];
    } else if (visitCount > 0) {
        cell.visitedLabel.layer.backgroundColor = [UIColor LDSOrangeColor].CGColor;
        cell.visitedLabel.textColor = [UIColor whiteColor];
    } else {
        cell.visitedLabel.textColor = [UIColor lightGrayColor];
    }
    
    // Top Border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 99.5, 320.0, 0.5);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [cell.layer addSublayer:topBorder];
}


@end

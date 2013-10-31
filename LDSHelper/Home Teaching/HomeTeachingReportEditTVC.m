//
//  HomeTeachingReportEditTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/21/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "HomeTeachingReportEditTVC.h"
#import "Visit.h"
#import "Person+AddOns.h"
#import "CommentsCell.h"
#import "GenericMemberCell.h"
#import "GenericCellWithButton.h"
#import "Organization.h"


@interface HomeTeachingReportEditTVC () <UIActionSheetDelegate, UITextViewDelegate>

@property (strong, nonatomic) Visit *visit;
@property (assign, nonatomic) BOOL isNew;
@property (assign, nonatomic) BOOL hasCommentsChanged;
@property (weak, nonatomic) Organization *organization;

@end

@implementation HomeTeachingReportEditTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ddLogLevel = LOG_LEVEL_VERBOSE;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericMemberCell" bundle:nil]
         forCellReuseIdentifier:@"Member Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GenericCellWithButton" bundle:nil] forCellReuseIdentifier:@"Delete Cell"];
    
    [self setupView];
}


- (void)setupView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentsCell" bundle:nil]
         forCellReuseIdentifier:@"Comments Cell"];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self setViewTitle];
}


- (void)setViewTitle
{
    if (self.isCompanionshipView) {
        NSMutableString *title = [[NSMutableString alloc] init];
        NSOrderedSet *persons = self.companionship.companions;
        Person *person = persons[0];
        [title appendString:person.firstName];
        if ([persons count] > 1) {
            person = persons[1];
            [title appendString:@" & "];
            [title appendString:person.firstName];
        }
        self.navigationItem.title = title;
        
    } else {
        self.navigationItem.title = [self currentMonth];
    }
}


- (NSString *)currentMonth
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM"];
    
    return [dateFormatter stringFromDate:self.currentDate];
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


- (void)setCompanionship:(Companionship *)companionship
{
    _companionship = companionship;
    
    self.visit = [Visit findFirstWithPredicate:[NSPredicate predicateWithFormat:@"date = %@ AND companionship = %@",
                                                  self.currentDate, companionship]];
    
    if (!self.visit) {
        self.isNew = YES;
        DDLogInfo(@"+ + + Creating new Visit Entity {%i}", self.isNew);
        self.visit = [Visit createEntity];
        self.visit.companionship = companionship;
        self.visit.date = self.currentDate;
    }
}


- (Organization *) organization {
    return [[Config sharedConfig] currentOrganization];
}


- (void)setupCell:(GenericMemberCell *)cell withPerson:(Person *)person
{
    cell.nameLabel.text = person.fullName;
    
    if (person.thumbnailSmall) {
        cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
        cell.initialsLabel.text = @"";
    } else {
        cell.thumbnailImage.image = nil;
        cell.initialsLabel.text = person.initials;
    }
}


- (void)setupCheckedCell:(GenericMemberCell *)cell withPerson:(Person *)person checked:(BOOL)checked
{
    if (checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.nameLabel.textColor = [Config colorForOrganization:self.organization.name];
        cell.initialsLabel.textColor = [Config colorForOrganization:self.organization.name];
        
        if (person.thumbnailSmall) {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailSmall];
            cell.initialsLabel.text = @"";
        } else {
            cell.thumbnailImage.image = nil;
            cell.initialsLabel.text = person.initials;
        }
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.nameLabel.textColor = [UIColor darkGrayColor];
        cell.initialsLabel.textColor = [UIColor darkGrayColor];
        
        if (person.thumbnailGraySmall) {
            cell.thumbnailImage.image = [UIImage imageWithData:person.thumbnailGraySmall];
            cell.initialsLabel.text = @"";
        } else {
            cell.thumbnailImage.image = nil;
            cell.initialsLabel.text = person.initials;
        }
    }
}


# pragma mark - Navigation

- (void)cancel:(id)sender
{
    DDLogVerbose(@"+ + + isNew {%i}", self.isNew);
    if (self.isNew == YES) {
        DDLogInfo(@"+ + + Deleting not saved object");
        [[NSManagedObjectContext defaultContext] deleteObject:self.visit];
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    } else {
        DDLogInfo(@"+ + + Resetting the Visit bc of a Cancel!");
        // Refresh Person objects, to avoid "Dangling reference to an invalid object." error.
        NSMutableSet *visited = [[NSMutableSet alloc] initWithSet:[self.visit visited]];
        for (Person *person in visited) {
            [[NSManagedObjectContext defaultContext] refreshObject:person mergeChanges:NO];
        }
        
        [[NSManagedObjectContext defaultContext] refreshObject:self.visit mergeChanges:NO];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)save:(id)sender
{
    if ([self.visit.visited count] == 0 && [self.visit.comment length] == 0) {
        DDLogInfo(@"+ + + Deleting because didn't visit anyone and there's no comment!");
        [[NSManagedObjectContext defaultContext] deleteObject:self.visit];
    } else {
        self.visit.comment = [self.visit.comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    DDLogVerbose(@"+ + + New comment: {%@}", self.visit.comment);
    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    [self.delegate updatedVisit:self];
}


#pragma mark - UIActionSheetDelegate Delete Companionship

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Delete"]) {
        DDLogInfo(@"Deleting Companionship");
        [[NSManagedObjectContext defaultContext] deleteObject:self.visit];
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
        [self.delegate deletedVisit:self];
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        self.visit.comment = textView.text;
        [textView resignFirstResponder];
        // Move to top
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:YES];
        return NO;
    }
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    self.hasCommentsChanged = YES;
    
    NSString *noNewLineChars = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    self.visit.comment = noNewLineChars;
    if (![noNewLineChars isEqualToString:textView.text]) {
        // Updated the textView because it contained extra spaces/new line chars, can happen when pasting
        DDLogVerbose(@"Removed \\n from {%@}", textView.text);
        textView.text = self.visit.comment;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isCompanionshipView) {
        return 3;
    }
    
    return [super numberOfSectionsInTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDLogVerbose(@"+ + + Section {%i}", section);
    if (!self.isCompanionshipView && section == 0) {
        return 2;
    }
    if ((self.isCompanionshipView && section == 0) || (!self.isCompanionshipView && section == 1)) {
        DDLogVerbose(@"+ + + + visits: {%i}", [self.companionship.visits count]);
        return [self.companionship.visits count];
    }
    if (self.isCompanionshipView && section == 1) {
        DDLogVerbose(@"+ + + + 1");
        return 1;
    }
    DDLogVerbose(@"+ + + + {%i}", [super tableView:tableView numberOfRowsInSection:section]);
    if (self.isCompanionshipView) {
        return [super tableView:tableView numberOfRowsInSection:section+1];
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isCompanionshipView && indexPath.section == 0) {
        return [self companionCellForRowAtIndexPath:indexPath];
        
    } else if ((self.isCompanionshipView && indexPath.section == 0)
               || (!self.isCompanionshipView && indexPath.section == 1)) {
        DDLogVerbose(@"+ + + IndexPath: r{%i}s{%i}", indexPath.row, indexPath.section);
        return [self memberCellForRowAtIndexPath:indexPath];
        
    } else if ((self.isCompanionshipView && indexPath.section == 1)
               || (!self.isCompanionshipView && indexPath.section == 2)) {
        return [self commentCellForRowAtIndexPath:indexPath];
        
    } else if ((self.isCompanionshipView && indexPath.section == 2) || (!self.isCompanionshipView && indexPath.section == 3)) {
        return [self deleteCellForRowAtIndexPath:indexPath];
    }
    
    DDLogError(@"Invalid section");
    NSAssert(false, @"Invalid section");

    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.isCompanionshipView && indexPath.section == 0)
        || (!self.isCompanionshipView && indexPath.section == 1)) {
        
        GenericMemberCell *cell = (GenericMemberCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        Person *person = self.companionship.visits[indexPath.row];
        NSMutableSet *visited = [[NSMutableSet alloc] initWithSet:[self.visit visited]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [visited removeObject:person];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self setupCheckedCell:cell withPerson:person checked:NO];
        } else {
            [visited addObject:person];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self setupCheckedCell:cell withPerson:person checked:YES];
        }
        
        self.visit.visited = visited;
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isCompanionshipView && section == 0) {
        return [NSString stringWithFormat:@"Visited in %@", [self currentMonth]];
    } else if (self.isCompanionshipView) {
        // +1 Offset because companionships are not shown
        return [super tableView:tableView titleForHeaderInSection:section+1];
    }
    
    return [super tableView:tableView titleForHeaderInSection:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Companionship or Members
    if ((self.isCompanionshipView && indexPath.section == 0)
        || (!self.isCompanionshipView && (indexPath.section == 0 || indexPath.section == 1))) {
        
        return 74;
        
    }
    // Comments cell
    else if (indexPath.section == 1 || (!self.isCompanionshipView && indexPath.section == 2)) {
        return 150;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


#pragma mark - Table View heper methods

- (UITableViewCell *)companionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Member Cell";
    
    GenericMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        Person *person = [self.companionship.companions objectAtIndex:indexPath.row];
        [self setupCell:cell withPerson:person];
        
    } else if ([self.companionship.companions count] > 1) {
        Person *person = [self.companionship.companions objectAtIndex:indexPath.row];
        [self setupCell:cell withPerson:person];
        
    } else {
        cell.nameLabel.text = @"";
    }
    
    return cell;
}


- (UITableViewCell *)memberCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Member Cell";
    
    GenericMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Person *person = [self.companionship.visits objectAtIndex:indexPath.row];
    [self setupCell:cell withPerson:person];
    
    if ([self.visit.visited containsObject:person]) {
        [self setupCheckedCell:cell withPerson:person checked:YES];
    } else {
        [self setupCheckedCell:cell withPerson:person checked:NO];
    }
    
    return cell;
}


- (UITableViewCell *)commentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Comments Cell";
    
    CommentsCell *commentsCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    commentsCell.textView.text = self.visit.comment;
    commentsCell.textView.delegate = self;
    
    return commentsCell;
}


- (UITableViewCell *)deleteCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Delete Cell";
    
    GenericCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.deleteButton addTarget:self action:@selector(showDeleteActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [cell.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    return cell;
}


@end

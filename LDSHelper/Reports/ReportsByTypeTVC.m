//
//  ReportsByTypeTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/27/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "ReportsByTypeTVC.h"
#import "Report+FormattedDate.h"
#import "Organization.h"
#import "Companionship.h"
#import "Person.h"
#import "AssistanceReport.h"
#import "HomeTeachingReport.h"
#import "NSDate+Reporting.h"
#import "TSMessage.h"
#import "TSMessageView.h"
#import "ReportViewerVC.h"
#import "ReportCell.h"

@interface ReportsByTypeTVC () <ReportViewerProtocol, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate> {
    Boolean canCreateReport;
    int indexForSelectedRowInPicker;
}

@property (weak, nonatomic) Organization *organization;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *dateCreatedFormatter;

@property (strong, nonatomic) UIActionSheet *pickerViewActionSheet;
@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) NSArray *datesForDisplay;
@property (strong, nonatomic) NSDate *selectedDate;

@property (strong, nonatomic) Report *selectedReport;

@end

@implementation ReportsByTypeTVC

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
    
    [self setupView];
}

- (void)setupView
{
    self.title = ReportType_FullString[self.reportType];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.dateCreatedFormatter = [[NSDateFormatter alloc] init];
    [self.dateCreatedFormatter setDateFormat:@"('created on ' MMM, dd)"];
    
    // According to the reportType, get the needed data
    if ([self isDrivenByDates]) {
        indexForSelectedRowInPicker = 0;
        [self getDates];
    } else {
        self.selectedDate = [NSDate firstDayOfMonth];
        [self determineCanCreateReportForNonDateDrivenReports];
    }
}

- (void)setReportType:(ReportType)reportType
{
    _reportType = reportType;
    
    [self setupFetchedResultsController];
}

- (Organization *)organization
{
    if (!_organization) {
        _organization = [[Config sharedConfig] currentOrganization];
    }
    return _organization;
}

- (IBAction)newReport:(id)sender
{
    if (canCreateReport) {
        if ([self isDrivenByDates]){
            [self showPicker];
        } else {
            [self createReport];
        }
    } else {
        [self showNoDataMessage];
    }
}

- (void)showNoDataMessage
{
    NSString *message = [NSString stringWithFormat:@"Go to %@ and <play with the App>, then come back and create a report", ReportType_FullString[self.reportType]];
    
    [TSMessage showNotificationInViewController:self
                                          title:@"No Data for a New Report"
                                       subtitle:message
                                           type:TSMessageNotificationTypeWarning];
}

- (void)showPicker
{
    self.pickerViewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Date"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    // Add the picker
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    [pickerView selectRow:indexForSelectedRowInPicker inComponent:0 animated:NO];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    

    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelReport)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:self
                                                                               action:nil];
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(createReport)];
    
    [pickerToolbar setItems:@[cancelButton, flexSpace, createButton]];
    [self.pickerViewActionSheet addSubview:pickerToolbar];
    [self.pickerViewActionSheet addSubview:pickerView];
    [self.pickerViewActionSheet showInView:self.view];
    [self.pickerViewActionSheet setBounds:CGRectMake(0, 0, self.view.frame.size.width, 464)];
    [pickerToolbar sizeToFit];
}

// TODO: update with correct reports
- (void)createReport
{
    if (kLDSAssistance == self.reportType) {
        DDLogVerbose(@"Creating Assistance Report");
        AssistanceReport *assistanceReport = [[AssistanceReport alloc] init];
        NSString *path = [assistanceReport createReportWithDate:self.selectedDate];
        self.selectedReport = [self saveReport:path];
        [self.pickerViewActionSheet dismissWithClickedButtonIndex:1 animated:YES];
        [self performSegueWithIdentifier:@"View Report" sender:self];
        
    } else if (kLDSCompanionships == self.reportType) {
        DDLogVerbose(@"Creating Companionships Report");
        AssistanceReport *assistanceReport = [[AssistanceReport alloc] init];
        NSString *path = [assistanceReport createReportWithDate:self.selectedDate];
        self.selectedReport = [self saveReport:path];
        [self.pickerViewActionSheet dismissWithClickedButtonIndex:1 animated:YES];
        [self performSegueWithIdentifier:@"View Report" sender:self];
        
    } else if (kLDSHomeTeaching == self.reportType) {
        DDLogVerbose(@"Creating Home Teaching Report {%@}", self.selectedDate);
        HomeTeachingReport *homeTeachingReport = [[HomeTeachingReport alloc] init];
        NSString *path = [homeTeachingReport createReportWithDate:self.selectedDate];
        self.selectedReport = [self saveReport:path];
        [self.pickerViewActionSheet dismissWithClickedButtonIndex:1 animated:YES];
        [self performSegueWithIdentifier:@"View Report" sender:self];
        
    } else if (kLDSMembers == self.reportType) {
        DDLogVerbose(@"Creating Members Report");
        HomeTeachingReport *homeTeachingReport = [[HomeTeachingReport alloc] init];
        NSString *path = [homeTeachingReport createReportWithDate:self.selectedDate];
        self.selectedReport = [self saveReport:path];
        [self.pickerViewActionSheet dismissWithClickedButtonIndex:1 animated:YES];
        [self performSegueWithIdentifier:@"View Report" sender:self];
        
    } else {
        DDLogError(@"Bad Report Type: (%i)", self.reportType);
    }
    
    DDLogVerbose(@"Create report and go to View report");
}

- (Report *)saveReport:(NSString *)pathToReport
{
    NSData *pdfFile = [[NSData alloc] initWithContentsOfFile:pathToReport];
    
    Report *report = [Report createEntity];
    report.date = [NSDate firstDayOfMonth:self.selectedDate];
    report.dateCreated = [NSDate date];
    report.type = ReportType_Str[self.reportType];
    report.file = pdfFile;
    report.forOrganization = self.organization;
    
    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:pathToReport error:nil];
    
    return report;
}

- (void)cancelReport
{
    [self.pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

// Get the dates available to create a report, create the array for displayDates
- (void)getDates
{
    NSMutableArray *dates = [NSMutableArray new];
    NSMutableArray *datesForDisplay = [NSMutableArray new];
    
    if (kLDSAssistance == self.reportType) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Assistance"];
        request.predicate = [NSPredicate predicateWithFormat:@"organization = %@", self.organization];
        request.propertiesToFetch = @[@"firstDayOfMonth"];
        request.returnsDistinctResults = YES;
        request.resultType = NSDictionaryResultType;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstDayOfMonth" ascending:YES]];
        
        NSArray *dateDictionary = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:nil];
        NSDate *firstDayOfMonth = [NSDate firstDayOfMonth];
        
        DDLogVerbose(@"dateDictionary: %@", dateDictionary);
        
        [dateDictionary enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDate *date = obj[@"firstDayOfMonth"];
            [dates addObject:date];
            [datesForDisplay addObject:[self.dateFormatter stringFromDate:date]];
            if ([date compare:firstDayOfMonth] == NSOrderedSame) {
                indexForSelectedRowInPicker = idx;
            }
        }];
        
    } else if (kLDSHomeTeaching == self.reportType) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visit"];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY companionship.inOrganization = %@", self.organization];
        request.propertiesToFetch = @[@"date"];
        request.returnsDistinctResults = YES;
        request.resultType = NSDictionaryResultType;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        
        NSArray *dateDictionary = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:nil];
        NSDate *firstDayOfMonth = [NSDate firstDayOfMonth];
        
        [dateDictionary enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDate *date = obj[@"date"];
            [dates addObject:date];
            [datesForDisplay addObject:[self.dateFormatter stringFromDate:date]];
            if ([date compare:firstDayOfMonth] == NSOrderedSame) {
                indexForSelectedRowInPicker = idx;
            }
        }];
        
    } else {
        DDLogError(@"Invalid reportType: %@", ReportType_FullString[self.reportType]);
        NSAssert(true, @"Invalid ReportType");
    }
    
    // Set date properties
    self.dates = [NSArray arrayWithArray:dates];
    self.datesForDisplay = [NSArray arrayWithArray:datesForDisplay];
    
    if ([self.dates count] > 0) {
        canCreateReport = YES;
        self.selectedDate = self.dates[0];
    }
    
    DDLogCVerbose(@"dates: %@", self.dates);
    DDLogCVerbose(@"datesForDisplay: %@", self.datesForDisplay);
}

- (void)determineCanCreateReportForNonDateDrivenReports
{
    canCreateReport = NO;
    
    if (kLDSCompanionships == self.reportType) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Companionship"];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY inOrganization = %@", self.organization];
        NSArray *companionships = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:nil];
        
        if ([companionships count] > 0) {
            canCreateReport = YES;
        }
        
    } else if (kLDSMembers == self.reportType) {
        Person *person = [Person findFirstByAttribute:@"memberOf" withValue:self.organization];
        if (person) {
            canCreateReport = YES;
        }
        
    } else {
        DDLogError(@"Invalid reportType: %@", ReportType_FullString[self.reportType]);
        NSAssert(true, @"Invalid ReportType");
    }
}

// YES if the Report is usually generated every month (e.g. Home Teaching reports)
- (BOOL)isDrivenByDates
{
    if (self.reportType == kLDSAssistance || self.reportType == kLDSHomeTeaching) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Report"]) {
        DDLogVerbose(@"Trying to View Report");
        ReportViewerVC *vc = [segue destinationViewController];
        vc.report = self.selectedReport;
        vc.reportType = self.reportType;
        vc.delegate = self;
        self.selectedReport = nil;
        
    } else {
        NSAssert(true, @"Invalid segue identifier");
    }
}

- (void)deletedReport:(ReportViewerVC *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.datesForDisplay count];
}

#pragma mark - UIPickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.datesForDisplay objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    DDLogVerbose(@"Chose item: %@", [self.datesForDisplay objectAtIndex:row]);
    self.selectedDate = [self.dates objectAtIndex:row];
}

#pragma mark - Table view data source

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"forOrganization = %@ AND type = %@",
                         self.organization, ReportType_Str[self.reportType]];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:[NSManagedObjectContext defaultContext]
                                     sectionNameKeyPath:@"formattedDate"
                                     cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Report Cell";
    ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Report *report = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.dateLabel.text = [self.dateFormatter stringFromDate:report.date];
    cell.creationDateLabel.text = [self.dateCreatedFormatter stringFromDate:report.dateCreated];
    
    if ([report.isFavorite boolValue]) {
        cell.favoriteImage.image = [UIImage imageNamed:@"favorite_full"];
    } else {
        cell.favoriteImage.image = [UIImage imageNamed:@"favorite_outline"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedReport = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"View Report" sender:self];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [NSArray new];
}

@end

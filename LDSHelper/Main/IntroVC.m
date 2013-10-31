//
//  IntroVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "IntroVC.h"
#import "OrganizationChooserVC.h"
#import "Person+AddOns.h"
#import "Companionship+WithGeneratedSortingName.h"
#import "Visit.h"
#import "NSDate+Reporting.h"
#import "Assistance+FirstDayOfMonth.h"
#import "Report.h"
#import "Constants.h"
#import "Common.h"
#import "AssistanceReport.h"
#import "HomeTeachingReport.h"

@interface IntroVC ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *imageArray;

@end

@implementation IntroVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ddLogLevel = LOG_LEVEL_VERBOSE;
    
    [self loadDefaultData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ddLogLevel = LOG_LEVEL_WARN;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageArray = @[@"intro01.png", @"intro02.png", @"intro03.png", @"intro04.png"];
    
    for (int i = 0; i <[self.imageArray count]; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:[self.imageArray objectAtIndex:i]];
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.imageArray count], self.scrollView.frame.size.height);
}

- (IBAction)startPressed:(UIButton *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kLDSHasViewedIntro];
    [defaults synchronize];
    
    // Show Organization Chooser
    OrganizationChooserVC *organizationChooserVC = [[UIStoryboard mainStoryboard]
                                                    instantiateViewControllerWithIdentifier:@"Organization Chooser"];
    [self.revealViewController setFrontViewController:organizationChooserVC animated:YES];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - Load Default/Debug data

- (void)loadDefaultData
{
    Organization *organization = [Organization findFirst];
    
    if (!organization) {
        NSLog(@"Creating default Organizations");
        organization = [Organization createEntity];
        organization.name = @"Elders Quorum";
        organization = [Organization createEntity];
        organization.name = @"Relief Society";
        organization = [Organization createEntity];
        organization.name = @"Young Men";
        organization = [Organization createEntity];
        organization.name = @"Young Women";
        organization = [Organization createEntity];
        organization.name = @"Primary";
        
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    }
    
#ifdef DEBUG
    organization = [Organization findFirstByAttribute:@"name" withValue:@"Elders Quorum"];
    
    Person *person = [Person findFirst];
    
    if (!person) {
        DDLogInfo(@"IntroVC: Adding default Persons");
        person = [Person createEntity];
        person.memberOf = organization;
        person.firstName = @"Peter";
        person.lastName = @"Griffin";
        person.streetAddress = @"1 Infinity Loop";
        person.city = @"Cupertino";
        person.state = @"California";
        person.primaryPhone = @"555-567-1234";
        person.mobilePhone = @"555-234-6789";
        person.zipCode = @"99123";
        person.email = @"peter@griffin.com";
        UIImage *image = [UIImage imageNamed:@"profile-pic"];
        [person setThumbnailDataFromImage:image];
        [person setThumbnailSmallDataFromImage:image];
        person = [Person createEntity];
        person.memberOf = organization;
        person.firstName = @"John";
        person.lastName = @"Jones";
        person = [Person createEntity];
        person.memberOf = organization;
        person.firstName = @"Paul";
        person.lastName = @"Ask";
        person = [Person createEntity];
        person.memberOf = organization;
        person.firstName = @"Mary";
        person.lastName = @"Jain";
        person = [Person createEntity];
        person.memberOf = organization;
        person.firstName = @"Tom";
        person.lastName = @"Hanky";
        person = [Person createEntity];
        person.memberOf = organization;
        person.firstName = @"Wil";
        person.lastName = @"Free";
        
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    }
    
    Person *peter = [Person findFirstByAttribute:@"firstName" withValue:@"Peter"];
    Person *john = [Person findFirstByAttribute:@"firstName" withValue:@"John"];
    Person *paul = [Person findFirstByAttribute:@"firstName" withValue:@"Paul"];
    Person *mary = [Person findFirstByAttribute:@"firstName" withValue:@"Mary"];
    Person *tom = [Person findFirstByAttribute:@"firstName" withValue:@"Tom"];
    Person *wil = [Person findFirstByAttribute:@"firstName" withValue:@"Wil"];
    
    
    Companionship *companionship = [Companionship findFirst];
    
    if (!companionship) {
        DDLogInfo(@"IntroVC: Adding default Companionships");
        companionship = [Companionship createEntity];
        
        companionship.inOrganization = [NSSet setWithObject:organization];
        companionship.companions = [NSOrderedSet orderedSetWithArray:@[peter, tom]];
        companionship.sortingName = @"sortingName";
        companionship.visits = [NSOrderedSet orderedSetWithArray:@[paul, john]];
        
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    }
    
    Visit *visit = [Visit findFirst];
    
    if (!visit) {
        DDLogInfo(@"IntroVC:: Adding default visits");

        visit = [Visit createEntity];
        visit.date = [NSDate firstDayOfMonth];
        visit.companionship = companionship;
        visit.visited = [NSSet setWithArray:@[paul, john]];
        
        // Will John Companionship
        Companionship *wilJohn = [Companionship createEntity];
        wilJohn.inOrganization = [NSSet setWithObject:organization];
        wilJohn.companions = [NSOrderedSet orderedSetWithArray:@[wil, john]];
        wilJohn.sortingName = @"";
        wilJohn.visits = [NSOrderedSet orderedSetWithObject:mary];
        
        Visit *wilJohnVisit = [Visit createEntity];
        wilJohnVisit.date = [NSDate firstDayOfMonth];
        wilJohnVisit.companionship = wilJohn;
        wilJohnVisit.visited = [NSSet setWithObject:mary];
        
        Visit *peterTomPrev = [Visit createEntity];
        peterTomPrev.date = [NSDate firstDayOfMonth:[NSDate date] byAddingMonths:-1];
        peterTomPrev.companionship = companionship;
        peterTomPrev.visited = [NSSet setWithObject:john];
        
        Visit *wilJohnVisitNext = [Visit createEntity];
        wilJohnVisitNext.date = [NSDate firstDayOfMonth:[NSDate date] byAddingMonths:1];
        wilJohnVisitNext.companionship = wilJohn;
        wilJohnVisitNext.visited = [NSSet setWithObject:mary];
        
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    }
    
    Report *report = [Report findFirst];
    
    if (!report) {
        DDLogInfo(@"IntroVC:: Adding default Reports");
        
        // Create dymmy reports with no file
        Report *companionships01 = [Report createEntity];
        companionships01.type = ReportType_Str[kLDSCompanionships];
        companionships01.date = [NSDate firstDayOfMonth];
        companionships01.dateCreated = [NSDate date];
        companionships01.forOrganization = organization;
        
        Report *companionships02 = [Report createEntity];
        companionships02.type = ReportType_Str[kLDSCompanionships];
        companionships02.date = [NSDate firstDayOfMonth:[NSDate date] byAddingMonths:-1];
        companionships02.dateCreated = [NSDate date];
        companionships02.forOrganization = organization;
        
        [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
        
        // Craete reports with actual PDF file
        HomeTeachingReport *htReport = [[HomeTeachingReport alloc] init];
        NSString *path = [htReport createReportWithDate:[NSDate firstDayOfMonth:[NSDate date] byAddingMonths:-1]];
        [self saveReport:kLDSHomeTeaching withPath:path withOrganization:organization forDate:[NSDate firstDayOfMonth:[NSDate date] byAddingMonths:-1]];
        
        htReport = [[HomeTeachingReport alloc] init];
        path = [htReport createReportWithDate:[NSDate date]];
        [self saveReport:kLDSHomeTeaching withPath:path withOrganization:organization forDate:[NSDate date]];
        
        AssistanceReport *assistanceReport = [[AssistanceReport alloc] init];
        path = [assistanceReport createReportWithDate:[NSDate date]];
        [self saveReport:kLDSAssistance withPath:path withOrganization:organization forDate:[NSDate date]];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@ AND forOrganization = %@ AND type = %@",
                                  [NSDate firstDayOfMonth], organization, ReportType_Str[kLDSHomeTeaching]];
        NSArray *reports = [Report findAllWithPredicate:predicate];
        
        for (Report *report in reports) {
            DDLogVerbose(@"%@ - %@", report.type, report.dateCreated);
        }
    }
    
//    // TEST: When Deleting a Person, a Companionship should be deleted too if this is the last person in the Companionship
//    
//    person = [Person createEntity];
//    person.memberOf = organization;
//    person.firstName = @"Michael";
//    person.lastName = @"";
//    
//    person = [Person createEntity];
//    person.memberOf = organization;
//    person.firstName = @"Jordan";
//    person.lastName = @"";
//    
//    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
//    
//    Person *michael = [Person findFirstByAttribute:@"firstName" withValue:@"Michael"];
//    Person *jordan = [Person findFirstByAttribute:@"firstName" withValue:@"Jordan"];
//    
//    Companionship *michaelJordan = [Companionship createEntity];
//    michaelJordan.inOrganization = [NSSet setWithObject:organization];
//    michaelJordan.companions = [NSOrderedSet orderedSetWithArray:@[michael, jordan]];
//    michaelJordan.sortingName = @"";
//    
//    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
//    
//    NSOrderedSet *companions = michael.companionedBy.companions;
//    DDLogVerbose(@"+ + Total companions for michael: {%i}", [companions count]);
//    for (Person *p in companions) {
//        DDLogVerbose(@"+ + {%@}", p.normalizedName);
//    }
//    
//    DDLogVerbose(@"+ + + + + Deleting Michael!!!");
//    [michael deleteEntity];
//    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
//    
//    DDLogVerbose(@"+ + + + 01 Deleting Jordan!!!");
//    [jordan deleteEntity];
//    DDLogVerbose(@"+ + + + 02 Deleting Jordan!!!");
//    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    
#endif
    
}

// Adapted from From ReportsByTypeTVC
- (void)saveReport:(ReportType)reportType withPath:(NSString *)pathToReport withOrganization:(Organization *)organization forDate:(NSDate *)date
{
    NSData *pdfFile = [[NSData alloc] initWithContentsOfFile:pathToReport];
    
    Report *report = [Report createEntity];
    report.date = [NSDate firstDayOfMonth:date];
    report.dateCreated = [NSDate date];
    report.type = ReportType_Str[reportType];
    report.file = pdfFile;
    report.forOrganization = organization;
    
    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:pathToReport error:nil];
}

@end

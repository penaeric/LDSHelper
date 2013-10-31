//
//  ReportViewerVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/28/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "ReportViewerVC.h"
#import "TSMessage.h"
#import "TSMessageView.h"
@import MessageUI;

@interface ReportViewerVC () <MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favButton;

@property (strong, nonatomic) Report *nextReport;
@property (strong, nonatomic) Report *prevReport;

@end

@implementation ReportViewerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];

    ddLogLevel = LOG_LEVEL_VERBOSE;
    [self setupView];
}

- (void)setupView
{
    self.webView.scalesPageToFit = YES;
    [self.webView loadData:self.report.file MIMEType:@"application/pdf" textEncodingName:nil baseURL:nil];
    
    if ([self.report.isFavorite isEqual:[NSNumber numberWithBool:YES]]) {
        self.favButton.tintColor = [UIColor orangeColor];
    }
    
    self.prevButton.enabled = NO;
    self.nextButton.enabled = NO;
    
    self.nextReport = [self findNextReport];
    self.prevReport = [self findPrevReport];
    
    if (self.nextReport) {
        DDLogVerbose(@"Next Report found: {%@} {%@}", self.nextReport.date, self.nextReport.dateCreated);
        self.nextButton.enabled = YES;
    }
    
    if (self.prevReport) {
        DDLogVerbose(@"Prev Report found: {%@} {%@}", self.prevReport.date, self.prevReport.dateCreated);
        self.prevButton.enabled = YES;
    }
}

- (Report *)findNextReport
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"((date = %@ AND dateCreated > %@) OR (date > %@)) AND type = %@ AND forOrganization = %@",
                         self.report.date, self.report.dateCreated, self.report.date, self.report.type, self.report.forOrganization];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    request.fetchLimit = 1;
    
    NSArray *fetchResults = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:nil];
    
    Report *nextReport = nil;
    if ([fetchResults count] > 0) {
        nextReport = fetchResults[0];
    }
    
    return nextReport;
}

- (Report *)findPrevReport
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"((date = %@ AND dateCreated < %@) OR (date < %@)) AND type = %@ AND forOrganization = %@",
                         self.report.date, self.report.dateCreated, self.report.date, self.report.type, self.report.forOrganization];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    
    request.fetchLimit = 1;
    
    NSArray *fetchResults = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:nil];
    
    Report *prevReport = nil;
    
    if ([fetchResults count] > 0) {
        prevReport = fetchResults[0];
    }
    
    return prevReport;
}

- (void)showEmail
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *reportTitle = [NSString stringWithFormat:@"%@ Report", ReportType_FullString[self.reportType]];
    NSString *emailTitle = [NSString stringWithFormat:@"%@ %@", kLDSApplicationName, reportTitle];
    NSString *messageBody = [NSString stringWithFormat:@"%@ Report for %@", reportTitle, [dateFormatter stringFromDate:self.report.date]];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    
    [mc addAttachmentData:self.report.file mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@.pdf", reportTitle]];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

#pragma mark - Navigation

- (IBAction)prevButtonPressed:(id)sender
{
    self.report = self.prevReport;
    [self setupView];
}

- (IBAction)favButtonPressed:(id)sender
{
    if ([self.report.isFavorite isEqual:[NSNumber numberWithBool:YES]]) {
        self.report.isFavorite = [NSNumber numberWithBool:NO];
        self.favButton.tintColor = nil;
        
    } else {
        self.report.isFavorite = [NSNumber numberWithBool:YES];
        self.favButton.tintColor = [UIColor orangeColor];
    }
    
    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
}

- (IBAction)printButtonPressed:(id)sender
{
    [self printPDF];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    [self.report deleteEntity];
    [[NSManagedObjectContext defaultContext] saveOnlySelfAndWait];
    [self.delegate deletedReport:self];
}

- (IBAction)emailButtonPressed:(id)sender
{
    [self showEmail];
}

- (IBAction)nextButtonPressed:(id)sender
{
    self.report = self.nextReport;
    [self setupView];
}

#pragma mark - Print PDF

// TODO: test
- (void)printPDF
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    if (pic && [UIPrintInteractionController canPrintData:self.report.file]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        pic.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = [NSString stringWithFormat:@"%@ - %@ Report (%@)", kLDSApplicationName, ReportType_FullString[self.reportType], [dateFormatter stringFromDate:self.report.date]];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.showsNumberOfCopies = YES;
        pic.printingItem = self.report.file;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            if (!completed && error) {
                DDLogError(@"Printing FAILED due to error in domain %@ with error code %u", error.domain, error.code);
            }
        };
        
        [pic presentAnimated:YES completionHandler:completionHandler];
        
    } else {
        DDLogError(@"Could not print file! Invalid file? (lenght: %i)", [self.report.file length]);
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Could not print the Report"
                                           subtitle:@"The PDF File might be corrupted, please try again"
                                               type:TSMessageNotificationTypeError];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DDLogVerbose(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            DDLogVerbose(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            DDLogVerbose(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            DDLogWarn(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

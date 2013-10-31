//
//  AssistanceVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "AssistanceVC.h"
#import "DayPickerVC.h"
#import "AssistanceTVC.h"
#import "MZDayPicker.h"

@interface AssistanceVC () <DayPickerDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *dayPickerContainer;
@property (weak, nonatomic) AssistanceTVC *tableView;

@end

@implementation AssistanceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
    
    self.revealViewController.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
}

// TODO: setup start and end dates correctly using dateByAddingUnit and nextDateAfterDate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DayPicker"]) {
        DayPickerVC *dayPicker = [segue destinationViewController];
        dayPicker.delegate = self;
        
        NSDate *dateTime = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                   fromDate:dateTime];
        NSDate *dateOnly = [calendar dateFromComponents:components];
        NSDate *startDate = [dateOnly dateByAddingTimeInterval:(-21.0 * 60.0 * 60.0 * 24.0)];
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                 fromDate:startDate];
        dayPicker.startDate = startDate;
        
        NSDate *endDate = [dateOnly dateByAddingTimeInterval:(91.0 * 60.0 * 60.0 * 24.0)];
        dayPicker.endDate = endDate;
    } else if ([segue.identifier isEqualToString:@"TableView"]) {
        self.tableView = [segue destinationViewController];
    }
}

- (void)didSelectDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.title = [dateFormatter stringFromDate:date];
    
//    self.tableView.currentDate = date;
    self.tableView.currentDate = [NSDate dateWithNoTime:date middleDay:YES];
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

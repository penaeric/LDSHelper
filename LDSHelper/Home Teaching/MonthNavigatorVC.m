//
//  MonthNavigatorVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/20/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MonthNavigatorVC.h"
#import "NSDate+Reporting.h"
#import "Visit.h"

@interface MonthNavigatorVC ()

@property (weak, nonatomic) IBOutlet UILabel *currentMonthLabel;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSArray *dates;
@property (nonatomic) NSUInteger indexOfCurrentDate;

@end

@implementation MonthNavigatorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setupView
{
    self.selectedDate = [NSDate firstDayOfMonth:[NSDate date]];
    
    [self updateTitle];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Visit"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"ANY companionship.inOrganization = %@",
                         [[Config sharedConfig] currentOrganization]];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"date"]];
    
    NSError *error;
    self.dates = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:&error];

    if (self.dates != nil) {
        // Only want the dates, no the dictionaries
        self.dates = [self.dates valueForKey:@"date"];
    } else {
        NSLog(@"Could not fetch dates: %@", [error localizedDescription]);
    }
    
    [self updateButtons];
}

- (void)updateTitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM"];
    self.currentMonthLabel.text = [dateFormatter stringFromDate:self.selectedDate];
}

- (void)updateButtons
{
    self.indexOfCurrentDate = [self.dates indexOfObject:self.selectedDate];
    
    if (self.indexOfCurrentDate != NSNotFound) {
        if (self.indexOfCurrentDate > 0) {
            self.prevButton.enabled = YES;
        } else {
            self.prevButton.enabled = NO;
        }
        
        if (self.indexOfCurrentDate >= [self.dates count] -1) {
            self.nextButton.enabled = NO;
        } else {
            self.nextButton.enabled = YES;
        }
        
    } else {
        self.prevButton.enabled = NO;
        self.nextButton.enabled = NO;
    }
}

- (IBAction)prevButtonPressed:(id)sender
{
    self.selectedDate = [NSDate firstDayOfMonth:self.selectedDate byAddingMonths:-1];
    [self.delegate didSelectDate:self.selectedDate];
    [self updateTitle];
    [self updateButtons];
}

- (IBAction)nextButtonPressed:(id)sender
{
    self.selectedDate = [NSDate firstDayOfMonth:self.selectedDate byAddingMonths:1];
    [self.delegate didSelectDate:self.selectedDate];
    [self updateTitle];
    [self updateButtons];
}

@end

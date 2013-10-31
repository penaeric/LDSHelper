//
//  HomeTeachingVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/19/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "HomeTeachingVC.h"
#import "MonthNavigatorVC.h"
#import "HomeTeachingTVC.h"
#import "Organization.h"

@interface HomeTeachingVC () <MonthNavigatorDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) HomeTeachingTVC *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmentedControl;
@property (weak, nonatomic) Organization *organization;

@end


@implementation HomeTeachingVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ddLogLevel = LOG_LEVEL_VERBOSE;
    
    self.revealViewController.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self setupView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
}


- (void)setupView
{
    DDLogVerbose(@"+ + + %@", [[Config sharedConfig] currentOrganization].name);
    if ([[[Config sharedConfig] currentOrganization].name isEqualToString:CurrentOrganization_FullString[kLDSReliefSociety]]) {
        self.title = @"Visiting Teaching Reports";
    }
    
    // TODO: check if right color
    self.viewTypeSegmentedControl.tintColor = [Config colorForOrganization:self.organization.name];
    [self.viewTypeSegmentedControl addTarget:self
                                      action:@selector(viewTypeWasSelected:)
                            forControlEvents:UIControlEventValueChanged];
    
    [self setViewTypeIndexInTableView];
}


- (void)setViewTypeIndexInTableView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger viewTypeIndex = [defaults integerForKey:kLDSHomeTeachingSelectedViewIndex];
    if (!viewTypeIndex){
        viewTypeIndex = 0;
        [defaults setInteger:viewTypeIndex forKey:kLDSHomeTeachingSelectedViewIndex];
    } else {
        self.viewTypeSegmentedControl.selectedSegmentIndex = viewTypeIndex;
    }
    
    DDLogVerbose(@"+ + + HomeTeachingVC:viewTypeIndex {%i}", viewTypeIndex);
    if (viewTypeIndex == 0) {
        self.tableView.isCompanionshipView = YES;
    } else {
        self.tableView.isCompanionshipView = NO;
    }
    
    [defaults synchronize];
}


- (Organization *)organization
{
    if (!_organization) {
        _organization = [[Config sharedConfig] currentOrganization];
    }
    return _organization;
}


- (void)viewTypeWasSelected:(id)sender
{
    if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
        DDLogVerbose(@"By Companionship");
        self.tableView.isCompanionshipView = YES;
    } else {
        DDLogVerbose(@"By Visit Status");
        self.tableView.isCompanionshipView = NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.viewTypeSegmentedControl.selectedSegmentIndex forKey:kLDSHomeTeachingSelectedViewIndex];
    [defaults synchronize];
}


#pragma mark - Navigation

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
}


#pragma mark - MonthNavitagorDelegate

- (void)didSelectDate:(NSDate *)date
{
    DDLogVerbose(@"+ + + HomeTeachingVC::New Selected Date: {%@}", date);
    self.tableView.currentDate = date;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Month Navigator"]) {
        MonthNavigatorVC *monthNavigator = [segue destinationViewController];
        monthNavigator.delegate = self;
        
    } else  if ([segue.identifier isEqualToString:@"Home Teaching TVC"]) {
        self.tableView = [segue destinationViewController];
        
        [self setViewTypeIndexInTableView];
    }
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

//
//  MenuTVC.m
//  LDSHelper
//
//  Created by Eric Pena on 9/14/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MenuTVC.h"
#import "MenuCell.h"
#import "UIColor+LDSColors.h"
#import "Organization.h"
@class Config;

@interface MenuTVC ()

@property (strong, nonatomic) NSArray *menus;
@property (strong, nonatomic) NSDictionary *currentViewStrToKey;
@property (weak, nonatomic) NSArray *currentMenu;

@end

@implementation MenuTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    ddLogLevel = LOG_LEVEL_VERBOSE;
    [self setupView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Needed to refresh the buttons
    [self.tableView reloadData];
    
    [super viewWillDisappear:animated];
}

- (void)setupView
{
    UINib *nib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Menu Cell"];
    
    self.currentViewStrToKey = @{
                                 CurrentView_Str[kLDSMembersView] : @(kLDSMembersView),
                                 CurrentView_Str[kLDSAssistanceView] : @(kLDSAssistanceView),
                                 CurrentView_Str[kLDSCompanionshipsView] : @(kLDSCompanionshipsView),
                                 CurrentView_Str[kLDSHomeTeachingView] : @(kLDSHomeTeachingView),
                                 CurrentView_Str[kLDSReportsView] : @(kLDSReportsView),
                                 CurrentView_Str[kLDSImportContactsView] : @(kLDSImportContactsView)
                                 };
}

- (NSArray *)currentMenu
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger currentOrganization = [defaults integerForKey:kLDSCurrentOrganization];
    
    return [[Config sharedConfig] menus][currentOrganization];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentMenu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentView = [defaults integerForKey:kLDSCurrentView];
    
    static NSString *CellIdentifier = @"Menu Cell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger view = [(NSNumber *)self.currentMenu[indexPath.row] integerValue];
    
    if (kLDSEmptyView == view) {
        [cell.button setTitle:@"" forState:UIControlStateNormal];
        [cell.button setImage:[UIImage new] forState:UIControlStateNormal];
        return cell;
    }
    
    [cell.button setTitle:CurrentView_FullString[view] forState:UIControlStateNormal];
    NSString *imageName = [NSString stringWithFormat:@"%@Menu", CurrentView_Str[view]];
    [cell.button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    // Highlight currently selected section
    if (currentView == view) {
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
        Organization *currentOrganization = [[Config sharedConfig] currentOrganization];
        [cell.button setTitleColor:[Config colorForSelectedMenuForOrganization:currentOrganization.name] forState:UIControlStateNormal];
    } else {
        cell.backgroundColor = [UIColor clearColor];
        [cell.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    cell.button.restorationIdentifier = CurrentView_Str[view];
    [cell.button addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)menuButtonPressed:(UIButton *)button
{
    DDLogVerbose(@"restorationIdentifier: {%@}", button.restorationIdentifier);
    
    if ([self.revealViewController.frontViewController.restorationIdentifier isEqualToString:button.restorationIdentifier]) {
        DDLogVerbose(@"Toggle {%@}", button.restorationIdentifier);
        [self.revealViewController revealToggle:self];
        
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *n = (NSNumber *)self.currentViewStrToKey[button.restorationIdentifier];
        [defaults setInteger:[n integerValue] forKey:kLDSCurrentView];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:button.restorationIdentifier bundle:nil];
        UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:button.restorationIdentifier];
        [self.revealViewController setFrontViewController:navigationController animated:YES];
    }
}

@end

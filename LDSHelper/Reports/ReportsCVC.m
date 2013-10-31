//
//  ReportsCVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/24/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "ReportsCVC.h"
#import "SectionCell.h"
#import "ReportsByTypeTVC.h"
#import "CellButton.h"

@interface ReportsCVC () <SWRevealViewControllerDelegate>

@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *sectionsFullName;
@property (strong, nonatomic) NSMutableDictionary *reportCount;

@end

@implementation ReportsCVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [[Config sharedConfig] navigationBarTitleAttributes];
    self.navigationController.navigationBar.translucent = [[Config sharedConfig] navigationBarTranslucency];
	
    self.revealViewController.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    ddLogLevel = LOG_LEVEL_VERBOSE;
    [super viewWillAppear:animated];
    
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ddLogLevel = LOG_LEVEL_WARN;
}

- (void)setupView
{
    self.navigationItem.title = @"Reports";
    
    // By using enums we can change the which sections have reports and we can set the order
    // it's tedious to translate to strings or ints, but it's very dynamic
    self.sections = @[
                      [NSNumber numberWithInt:kLDSHomeTeaching],
                      [NSNumber numberWithInt:kLDSAssistance],
                      [NSNumber numberWithInt:kLDSCompanionships],
                      [NSNumber numberWithInt:kLDSMembers]
                      ];
    
    // Set all the counters to 0
    self.reportCount = [NSMutableDictionary dictionaryWithCapacity:[self.sections count]];
    for (NSNumber *number in self.sections) {
        NSString *sectionName = ReportType_Str[[number integerValue]];
        DDLogVerbose(@"sectionName: {%@}", sectionName);
        self.reportCount[sectionName] = @0;
    }
    
    [self updateCounters];
}

- (void)updateCounters
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Report"];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Report"
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    NSAttributeDescription *typeDesc = [entity.attributesByName objectForKey:@"type"];
    NSExpression *keyExpression = [NSExpression expressionForKeyPath:@"date"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:"
                                                              arguments:@[keyExpression]];
    NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
    [description setName:@"count"];
    [description setExpression:countExpression];
    [description setExpressionResultType:NSInteger16AttributeType];
    
    request.propertiesToFetch = @[typeDesc, description];
    request.propertiesToGroupBy = @[typeDesc];
    request.resultType = NSDictionaryResultType;
    
    request.predicate = [NSPredicate predicateWithFormat:@"forOrganization = %@",
                         [[Config sharedConfig] currentOrganization]];
    
    NSArray *count = [[NSManagedObjectContext defaultContext] executeFetchRequest:request error:nil];
    
    for (NSDictionary *dict in count) {
        NSString *type = dict[@"type"];
        self.reportCount[type] = dict[@"count"];
    }
}

#pragma mark - Navigation

- (IBAction)revealMenu:(id)sender
{
    [self.revealViewController revealToggle:self];
}

- (void)cellSelected:(id)sender
{
    self.navigationItem.title = @""; // So that next screen only shows a "<" as back button
    [self performSegueWithIdentifier:@"Show Reports List" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Reports List"]) {
        ReportsByTypeTVC *tvc = [segue destinationViewController];
        tvc.reportType = ((CellButton *)sender).reportType;
    }
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.sections count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CellButton *cellButton = (CellButton *)cell.cellButton;
    NSString *sectionName = ReportType_Str[[self.sections[indexPath.row] integerValue]];
    
    cell.sectionLabel.text = ReportType_FullString[[self.sections[indexPath.row] integerValue]];
    cell.numberLabel.text = [self.reportCount[sectionName] stringValue];
    
    cellButton.reportType = [self.sections[indexPath.row] integerValue];
    [cellButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
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

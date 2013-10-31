//
//  AppDelegate.m
//  LDSHelper
//
//  Created by Eric Pena on 6/15/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "AppDelegate.h"
#import "IntroVC.h"
#import "OrganizationChooserVC.h"
#import "MembersTVC.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

int ddLogLevel = LOG_LEVEL_WARN;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [MagicalRecord setupCoreDataStack];
    
    SWRevealViewController *revealController;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger currentOrganization = [defaults integerForKey:kLDSCurrentOrganization];
    DDLogInfo(@"Current Organization: {%i}", currentOrganization);
    NSUInteger currentView = [defaults integerForKey:kLDSCurrentView];
    DDLogInfo(@"Current View: {%i}", currentView);
    if (currentView == 0) {
        DDLogWarn(@"Current View not set. First time using the App?");
        currentView = kLDSMembersView;
        [defaults setInteger:kLDSMembersView forKey:kLDSCurrentView];
    }
    
    if (![defaults objectForKey:kLDSHasViewedIntro]) {
        // Show Intro
        IntroVC *introVC = [[UIStoryboard mainStoryboard]
                            instantiateViewControllerWithIdentifier:@"Intro"];
        revealController = [[SWRevealViewController alloc] initWithRearViewController:nil
                                                                  frontViewController:introVC];
    } else if (!currentOrganization) {
        // Show Organization Chooser
        OrganizationChooserVC *organizationChooserVC = [[UIStoryboard mainStoryboard]
                                                        instantiateViewControllerWithIdentifier:@"Organization Chooser"];
        revealController = [[SWRevealViewController alloc] initWithRearViewController:nil
                                                                  frontViewController:organizationChooserVC];
        
    } else {
        // Load the current organization according to user defaults
        Organization *organization = [Organization findFirstByAttribute:@"name"
                                                              withValue:CurrentOrganization_FullString[currentOrganization]];
        [[Config sharedConfig] setCurrentOrganization:organization];

        // Set NavigattionBar appearance
        [[UINavigationBar appearance] setBarTintColor:[Config colorForOrganization:organization.name]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        UIViewController *menu = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"Menu"];
        UINavigationController *nc = [self getCurrentViewNavigationController:currentView];
        
        revealController = [[SWRevealViewController alloc] initWithRearViewController:menu
                                                                  frontViewController:nc];
    }
    
    self.viewController = revealController;
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogVerbose(@"Application Will Terminate");
    [self saveContext];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveContext
{
    NSError *error = nil;
    if ([NSManagedObjectContext defaultContext] != nil) {
        if ([[NSManagedObjectContext defaultContext] hasChanges] && ![[NSManagedObjectContext defaultContext] save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DDLogVerbose(@"Application Did Enter Background");
//    [self saveContext];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (UINavigationController *)getCurrentViewNavigationController:(CurrentView)currentView {
    UINavigationController *navigationController;
    
    if (kLDSMembersView == currentView) {
        navigationController = [[UIStoryboard membersStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
    
    } else if (kLDSAssistanceView == currentView) {
        navigationController = [[UIStoryboard assistanceStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
    
    } else if (kLDSCompanionshipsView == currentView) {
        navigationController = [[UIStoryboard companionshipsStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
    
    } else if (kLDSHomeTeachingView == currentView) {
        navigationController = [[UIStoryboard homeTeachingStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
    
    } else if (kLDSReportsView == currentView) {
        navigationController = [[UIStoryboard reportsStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
    
    } else if (kLDSImportContactsView == currentView) {
        navigationController = [[UIStoryboard importContactsStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
        
    } else {
        DDLogError(@"Can't instantiate storyboard. Bad currentView: {%i}", currentView);
        navigationController = [[UIStoryboard membersStoryboard] instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];
    }
    
    return navigationController;
}

@end

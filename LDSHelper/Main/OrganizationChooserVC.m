//
//  OrganizationChooserVC.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "OrganizationChooserVC.h"
#import "MembersTVC.h"
#import "Organization.h"
#import "MenuVC.h"
#import "UIColor+LDSColors.h"

@interface OrganizationChooserVC ()

@end

@implementation OrganizationChooserVC

- (IBAction)organizationButtonPressed:(UIButton *)sender
{
    CurrentOrganization selectedOrg = sender.tag;
    
    DDLogVerbose(@"Button {%@} pressed (%i) > {%@}", CurrentOrganization_Str[selectedOrg], selectedOrg, sender.titleLabel.text);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger currentOrg = [defaults integerForKey:kLDSCurrentOrganization];
    
    if ([CurrentOrganization_FullString[currentOrg] isEqualToString:sender.titleLabel.text]) {
        NSUInteger currentView = [defaults integerForKey:kLDSCurrentView];
        DDLogInfo(@"Going back to the current view (%@) with org: (%@)", CurrentView_Str[currentView], CurrentOrganization_FullString[currentOrg]);
        
        UINavigationController *navigationController = [[UIStoryboard storyboardWithName:CurrentView_Str[currentView] bundle:nil]
                                                        instantiateViewControllerWithIdentifier:CurrentView_Str[currentView]];

        [self.revealViewController setFrontViewController:navigationController animated:YES];
        
    } else {
        DDLogInfo(@"Changing to new Organization: {%@}", CurrentOrganization_FullString[selectedOrg]);
        
        [[UINavigationBar appearance] setBarTintColor:[Config colorForOrganization:
                                                       CurrentOrganization_FullString[selectedOrg]]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        // Save new Current Organization
        [defaults setInteger:selectedOrg forKey:kLDSCurrentOrganization];
        [defaults setInteger:kLDSMembersView forKey:kLDSCurrentView];
        [defaults synchronize];
        
        // Set the current organization
        Organization *organization = [Organization findFirstByAttribute:@"name"
                                                              withValue:CurrentOrganization_FullString[selectedOrg]];
        [[Config sharedConfig] setCurrentOrganization:organization];
        
        // Load the right VCs
        MenuVC *menu = [[UIStoryboard mainStoryboard]
                        instantiateViewControllerWithIdentifier:@"Menu"];
        [self.revealViewController setRearViewController:menu];
        
        MembersTVC *membersTVC = [[UIStoryboard storyboardWithName:CurrentView_Str[kLDSMembersView] bundle:nil]
                                  instantiateViewControllerWithIdentifier:CurrentView_Str[kLDSMembersView]];
        [self.revealViewController setFrontViewController:membersTVC animated:YES];
    }
}

@end

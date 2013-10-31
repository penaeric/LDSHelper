//
//  MenuVC.m
//  LDSHelper
//
//  Created by Eric Pena on 9/14/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "MenuVC.h"

@interface MenuVC ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *organizationButton;

@end

@implementation MenuVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger currentOrganization = [defaults integerForKey:kLDSCurrentOrganization];
    
    NSString *imageName = [NSString stringWithFormat:@"MenuBackground%@", CurrentOrganization_Str[currentOrganization]];
    self.backgroundImageView.image = [UIImage imageNamed:imageName];
    
    NSString *buttonTitle = CurrentOrganization_FullString[currentOrganization];
    [self.organizationButton setTitle:buttonTitle forState:UIControlStateNormal];
}

// TODO: send a message to self.frontViewController to clean up (save or undo changes?)
- (IBAction)organizationButton:(id)sender
{
    UINavigationController *organizationChooserVC = [[UIStoryboard mainStoryboard]
                                                     instantiateViewControllerWithIdentifier:@"Organization Chooser"];
    [self.revealViewController setFrontViewController:organizationChooserVC animated:YES];
}

@end

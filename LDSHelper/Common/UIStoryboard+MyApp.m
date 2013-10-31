//
//  UIStoryboard+MyApp.m
//  LDSHelper
//
//  Created by Eric Pena on 8/12/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "UIStoryboard+MyApp.h"

@implementation UIStoryboard (MyApp)

+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

+ (UIStoryboard *)membersStoryboard
{
    return [UIStoryboard storyboardWithName:@"Members" bundle:nil];
}

+ (UIStoryboard *)assistanceStoryboard
{
    return [UIStoryboard storyboardWithName:@"Assistance" bundle:nil];
}

+ (UIStoryboard *)companionshipsStoryboard
{
    return [UIStoryboard storyboardWithName:@"Companionships" bundle:nil];
}

+ (UIStoryboard *)homeTeachingStoryboard
{
    return [UIStoryboard storyboardWithName:@"HomeTeaching" bundle:nil];
}

+ (UIStoryboard *)reportsStoryboard
{
    return [UIStoryboard storyboardWithName:@"Reports" bundle:nil];
}

+ (UIStoryboard *)importContactsStoryboard
{
    return [UIStoryboard storyboardWithName:@"ImportContacts" bundle:nil];
}

@end

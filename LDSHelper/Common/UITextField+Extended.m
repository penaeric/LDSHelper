//
//  UITextField+Extended.m
//  LDSHelper
//
//  Created by Eric Pena on 6/27/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "UITextField+Extended.h"
#import <objc/runtime.h>

static char defaultHashKey;

@implementation UITextField (Extended)

- (UITextField *)nextTextField
{
    return objc_getAssociatedObject(self, &defaultHashKey);
}

- (void)setNextTextField:(UITextField *)nextTextField
{
    objc_setAssociatedObject(self, &defaultHashKey, nextTextField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

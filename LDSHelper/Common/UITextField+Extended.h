//
//  UITextField+Extended.h
//  LDSHelper
//
//  Created by Eric Pena on 6/27/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface UITextField (Extended)

/**
 * By setting a list of buttons, tapping the "Done" button moves to the next field
 */
@property (retain, nonatomic)UITextField *nextTextField;

@end

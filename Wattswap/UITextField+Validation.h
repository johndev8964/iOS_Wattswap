//
//  UITextField+Validation.h
//  fixtalk
//
//  Created by User on 5/6/15.
//  Copyright (c) 2015 Mutable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Validation)

- (BOOL)requiredText;
- (BOOL)validZipCode;
- (BOOL)validPhoneNumber;
- (BOOL)validEmailAddress;
- (BOOL)validUsername;
- (BOOL)validPassword;
- (BOOL)validAmount;

@end
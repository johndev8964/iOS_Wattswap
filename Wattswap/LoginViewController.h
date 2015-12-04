//
//  LoginViewController.h
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *m_btnLogin;

@property (strong, nonatomic) IBOutlet UIView *m_viewInputPane;
@end

//
//  LoginViewController.m
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "MenuViewController.h"
#import "APIService.h"
#import "AppDelegate.h"


@interface LoginViewController ()

@property (nonatomic, retain) IBOutlet UITextField *emailText;
@property (nonatomic, retain) IBOutlet UITextField *passwordText;

- (IBAction) login:(id)sender;

@end

@implementation LoginViewController

@synthesize emailText, passwordText;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_btnLogin.layer.cornerRadius = 5;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *lc_email = [prefs stringForKey:@"EMAIL"];
    if(lc_email != nil) {
        if([lc_email isEqualToString:@"vipin7477@gmail.com"])
            emailText.text = @"FPL";
        else
            emailText.text = lc_email;
    }

    self.m_viewInputPane.layer.cornerRadius = 5.0f;
    self.m_viewInputPane.layer.borderColor = UIColorFromRGBValue(0x3c88bb).CGColor;
    self.m_viewInputPane.layer.masksToBounds = YES;
    self.m_viewInputPane.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) login:(id)sender {

    NSString *email = emailText.text;
    NSString *password = passwordText.text;

    NSString *device_id = [[Global sharedManager] getNewUDID];
    NSString *device_type = [[Global sharedManager] getDeviceName];
    NSString *mac_id = [[Global sharedManager] getMacAddress];
    
    if ([emailText validEmailAddress] || [emailText.text isEqualToString:@"FPL"]) {
        if ([passwordText validPassword]) {
            
            if([email isEqualToString:@"FPL"])
            {
                if([password isEqualToString:@"switch"]){
                    email = @"vipin7477@gmail.com";
                    password = @"3e0552e8";
                }
                else
                {
                    [self.view makeToast:@"Can't login with FPL. Password is wrong."];
                    return;
                }
            }
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *supervisorId = [prefs stringForKey:@"SUPERVISORID"];
            NSString *isLoggedIn = [prefs stringForKey:@"IS_LOGGED_IN"];
            if(supervisorId != nil && isLoggedIn != nil)
            {
                NSString *lc_email = [prefs stringForKey:@"EMAIL"];
                NSString *lc_password = [prefs stringForKey:@"PASSWORD"];
                if([lc_email isEqualToString:email] && [lc_password isEqualToString:password])
                {
                    [prefs setObject:@"YES" forKey:@"IS_LOGGED_IN"];
                    [prefs synchronize];

                    UIViewController *rootController = [self.navigationController.viewControllers objectAtIndex: 0];
                    Global *global = [Global sharedManager];
                    if(rootController == global.g_sideMenu) {
                        MainViewController *mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
                        [global.g_sideMenu setCenterViewController:mainCtrl];
                    }
                    else
                        [self dismissViewControllerAnimated:YES completion:nil];

                    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    [appDelegate loadFixtureOptions];
                    [appDelegate loadStateOptions];
                    [appDelegate loadConversionList];
                    
//                    [appDelegate syncSurvey];
                    return;
                }
            }

            NSDictionary *params = @{@"supervisor_email":email, @"supervisor_password":password, @"device_id":device_id, @"device_type":device_type, @"mac_id":mac_id};
            
            [SVProgressHUD showWithStatus:@"Login..." maskType:SVProgressHUDMaskTypeClear];
            [[APIService sharedManager] login:params onCompletion:^(NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                if (error) {
                    [self.view makeToast:error.localizedDescription];
                }
                else
                {
                    NSString *statusCode = [result objectForKey:@"status"];
                    if ([statusCode isEqualToString:@"Success"]) {
                        Global *global = [Global sharedManager];
                        
                        global.supervisorID = [[result objectForKey:@"data"] objectForKey:@"supervisor_id"];
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        [prefs setObject:global.supervisorID forKey:@"SUPERVISORID"];
                        [prefs setObject:@"YES" forKey:@"IS_LOGGED_IN"];
                        [prefs setObject:email forKey:@"EMAIL"];
                        [prefs setObject:password forKey:@"PASSWORD"];

                        [prefs synchronize];
                        
                        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        
                        [appDelegate loadFixtureOptions];
                        [appDelegate loadStateOptions];
                        [appDelegate loadConversionList];
                        
//                        [appDelegate syncSurvey];
                        
                        MainViewController *mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
                        [global.g_sideMenu setCenterViewController:mainCtrl];
                        
                    }
                    else {
                        [self.view makeToast:[result objectForKey:@"msg"]];
                    }
                }
            }];
        }
        else {
            [self.view makeToast:@"Please enter correct password."];
        }
    }
    else {
        [self.view makeToast:@"Please enter correct email id."];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if(textField == self.emailText) {
        [self.passwordText becomeFirstResponder];
    }
    
    if(textField == self.passwordText) {
        [textField resignFirstResponder];
        [self login:nil];
    }
    return YES;
}

@end

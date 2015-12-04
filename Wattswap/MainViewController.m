//
//  MainViewController.m
//  Wattswap
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "MainViewController.h"
#import "MenuViewController.h"
#import "CoredataManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "NewSurveyViewController.h"
#import "DetailedSurveyViewController.h"

#import "SurveyPropertyTabPageViewController.h"

#import <UIView+Toast.h>


@interface MainViewController ()

@property (nonatomic, retain) IBOutlet UIButton *menuBtn;

@end

@implementation MainViewController

@synthesize todayNumOfSurveys, dropBoxSigninBtn, dropBoxSignoutBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processLogoutNotification:)
                                                 name:@"LOGOUT"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNetConnectedNotification:) name:@"NETWORK_CONNECTED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNetDisconnectedNotification:) name:@"NETWORK_DISCONNECTED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processPushNewSurveyPageNotification:) name:@"PUSH_NEWSERVEY" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {    
    todayNumOfSurveys.text = [NSString stringWithFormat:@"%d", [self fetchFloorsCountFromCoreData:[NSDate date]]];
    
    if (![[DBSession sharedSession] isLinked]) {
        dropBoxSigninBtn.hidden = false;
        dropBoxSignoutBtn.hidden = true;
    }
    else {
        dropBoxSigninBtn.hidden = true;
        dropBoxSignoutBtn.hidden = false;
    }
}

-(void)processPushNewSurveyPageNotification:(NSNotification*)notification
{
    Global *global = [Global sharedManager];
    SurveyInfo *survey = global.survey;
    global.surveyID = survey.ofp_sid;
    global.surveyName = survey.sname;
    global.surveyNamePath = [global.surveyName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    global.survey = survey;
    
    DetailedSurveyViewController *detailedSurveyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailedSurveyCtrl"];
    detailedSurveyCtrl.mustGoAddFloor = YES;
    [self.navigationController pushViewController:detailedSurveyCtrl animated:NO];
}

- (void)processNetDisconnectedNotification:(NSNotification*)notification
{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"Internet disconnected!"];
}

- (void)processNetConnectedNotification:(NSNotification*)notification
{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"Internet connected!"];
}

- (void)processLogoutNotification:(NSNotification*)notification
{
    LoginViewController *loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    [self presentViewController:loginCtrl animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) fetchFloorsCountFromCoreData : (NSDate *) todayDate {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SurveyInfo" inManagedObjectContext:coreDataContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"scheduled==%@", todayDate]];
    
    NSError *error;
    NSArray *array = [coreDataContext executeFetchRequest:request error:&error];
    
    return (int) [array count];
}

- (IBAction) showLeftMenu:(id)sender {
    [self showMenu];
}

- (IBAction) loginDropbox:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        dropBoxSigninBtn.hidden = true;
        dropBoxSignoutBtn.hidden = false;
    }
}

- (IBAction) logoutDropBox:(id)sender {
    dropBoxSigninBtn.hidden = false;
    dropBoxSignoutBtn.hidden = true;
    [[DBSession sharedSession] unlinkAll];
}

#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
{
    if (index != alertView.cancelButtonIndex) {
        [[DBSession sharedSession] linkFromController:[self.navigationController visibleViewController]];
    }
    //relinkUserId = nil;
}

- (void) showMenu {
    [((Global*)[Global sharedManager]).g_sideMenu toggleLeftSideMenuCompletion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MENU_PAGE_SHOWED" object:nil];
}

- (IBAction)onClickButtonAddNewSurvey:(id)sender {
    NewSurveyViewController *newSurveyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"NewSurveyCtrl"];
    [self.navigationController pushViewController:newSurveyCtrl animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end

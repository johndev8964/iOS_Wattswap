//
//  MenuViewController.m
//  Wattswap
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "MenuViewController.h"
#import "NewSurveyViewController.h"
#import "DetailedSurveyViewController.h"
#import "CoredataManager.h"
#import "SurveyTableViewCell.h"
#import "Constants.h"
#import "SurveyInfo.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "APIService.h"
#import "SettingsViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize navigationCtrl, surveyListsArray, openBtn, closeBtn, surveyLists, toggleOpenClose, refreshControl;

+ (id)sharedManager
{
    static MenuViewController *sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[[Global sharedManager] setUserInterface] bundle:nil];
        sharedManager = [mainStoryboard instantiateViewControllerWithIdentifier:@"MenuCtrl"];
    });
    return sharedManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processShowMenuNotification:) name:@"MENU_PAGE_SHOWED" object:nil];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onRefreshPhotos) forControlEvents:UIControlEventValueChanged];
    
    [surveyLists addSubview:refreshControl];
}

-(void) processShowMenuNotification:(NSNotification*)notification
{
    Global *global = [Global sharedManager];
    global.isUpdate = false;
    [self selectOpenSurveyLists:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Global *global = [Global sharedManager];
    global.isUpdate = false;
    [self selectOpenSurveyLists:nil];
}

- (void)onRefreshPhotos {
    
    Sync2Server *sync2Server = [Sync2Server sharedSyncManager];
    sync2Server.delegate = self;
    [sync2Server startSync2RtDB];
    [sync2Server startSync2LcDB];
}

#pragma mark - Sync2ServerDelegate
- (void) didFinished2RtDBWithResult:(NSString*)result Error:(NSError *)error {
    [refreshControl endRefreshing];
    if([result isEqualToString:@"success"]) {
        [self selectOpenSurveyLists:nil];
    }
}

- (void) didFinished2LcDBWithResult:(NSString*)result Error:(NSError *)error {
    [refreshControl endRefreshing];
    if([result isEqualToString:@"success"]) {
        [self selectOpenSurveyLists:nil];
    }
}

-(void) updateServeryTree:(SurveyInfo*)surveyInfo IsLastSurvey:(BOOL)lastSurvey {
    
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    NSDictionary *params = @{@"survey_id": surveyInfo.sid};
    [[APIService sharedManager] getSurveyTreeFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
        if(lastSurvey) {
            [refreshControl endRefreshing];
            [SVProgressHUD dismiss];
        }

        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSMutableDictionary *surveyData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"success"])
            {
                NSArray *floors = [surveyData objectForKey:@"floors"];
                for(int f=0; f<[floors count]; f++) {

                    FloorInfo *floorInfo = nil;
                    NSDictionary *floorDict = [floors objectAtIndex:f];
                    NSArray *candis = [APIService getObjectsFromCoreData:@"FloorInfo" IDName:@"fid" IDValue:[floorDict objectForKey:@"floor_id"]];
                    if(candis != nil) floorInfo = [candis objectAtIndex:0];
                    if( floorInfo == nil)
                    {
                        floorInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
                        
                        floorInfo.ofp_sid = surveyInfo.ofp_sid;
                        floorInfo.ofp_fid = [global getMaxFloorValue:YES];
                        [floorInfo initWithDict:floorDict];
                    }
                    else {
                        NSString *lastModified = [floorDict objectForKey:@"last_modified"];
                        NSDate *stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd"];
                        if(floorInfo.stime < stime) {
                            [floorInfo initWithDict:floorDict];
                        }
                    }
                    
                    NSArray *areas = [surveyData objectForKey:@"areas"];
                    for(int a=0; a < [areas count]; a ++) {
                        
                        AreaInfo *areaInfo = nil;
                        NSDictionary *areaDict = [areas objectAtIndex:a];
                        NSArray *candis = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"aid" IDValue:[areaDict objectForKey:@"area_id"]];
                        if(candis != nil) areaInfo = [candis objectAtIndex:0];
                        if( areaInfo == nil)
                        {
                            areaInfo = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
                            
                            areaInfo.ofp_sid = surveyInfo.ofp_sid;
                            areaInfo.ofp_fid = floorInfo.ofp_fid;
                            areaInfo.ofp_aid = [global getMaxAreaValue:YES];
                            [areaInfo initWithDict:areaDict];
                        }
                        else {
                            NSString *lastModified = [areaDict objectForKey:@"last_modified"];
                            NSDate *stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd"];
                            if(areaInfo.stime < stime) {
                                [areaInfo initWithDict:areaDict];
                            }
                        }
                        
                        NSArray *fixtures = [surveyData objectForKey:@"fixtures"];
                        for(int x = 0; x < [fixtures count]; x++) {
                            
                            FixtureInfo *fixtureInfo = nil;
                            NSDictionary *fixtureDict = [fixtures objectAtIndex:x];
                            NSArray *candis = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"fixtureid" IDValue:[fixtureDict objectForKey:@"fixture_id"]];
                            if(candis != nil) fixtureInfo = [candis objectAtIndex:0];
                            if( fixtureInfo == nil)
                            {
                                fixtureInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
                                
                                fixtureInfo.ofp_sid = surveyInfo.ofp_sid;
                                fixtureInfo.ofp_fid = floorInfo.ofp_fid;
                                fixtureInfo.ofp_aid = areaInfo.ofp_aid;
                                fixtureInfo.ofp_fixtureid = [global getMaxFixtureValue:YES];
                                [fixtureInfo initWithDict:fixtureDict];
                            }
                            else {
                                NSString *lastModified = [fixtureDict objectForKey:@"create_ts"];
                                NSDate *stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd"];
                                if(fixtureInfo.stime < stime) {
                                    [fixtureInfo initWithDict:fixtureDict];
                                }
                            }
                        }
                    }
                }
                
                NSError *error1;
                [coreDataContext save:&error1];
            }
        }
        if(lastSurvey) {
            [self selectOpenSurveyLists:nil];
        }
    }];
}

- (void) fetchCoreData {
    
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SurveyInfo" inManagedObjectContext:coreDataContext];
    
    [fetchRequest setEntity:entityDescription];
    
    Global *global = [Global sharedManager];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"supervisor_id == %@", global.supervisorID]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"scheduled" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray* array = [coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    surveyListsArray = [[NSMutableArray alloc] init];
    
    for (SurveyInfo *surveyInfo in array) {
        [surveyListsArray addObject:surveyInfo];
    }
}

- (IBAction)onClickBtnSettings:(id)sender {
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) addNewSurvey:(id)sender {
    NewSurveyViewController *newSurveyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"NewSurveyCtrl"];
    [self.navigationController pushViewController:newSurveyCtrl animated:YES];
}

- (IBAction) selectOpenSurveyLists:(id)sender {
    toggleOpenClose = YES;
    [openBtn setTitleColor:[UIColor colorWithHexString:OPEN_STATE_COLOR] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithHexString:CLOSE_STATE_COLOR] forState:UIControlStateNormal];
    
    [self fetchCoreData];
    
    for (int i=0;i<[surveyListsArray count]; i++) {
        SurveyInfo *_survey = [surveyListsArray objectAtIndex:i];
        if([_survey.scheduled compare: [[Global sharedManager] getDateFromString:[[Global sharedManager] getStringFromDate:[NSDate date] Format:@"M-d-yyyy"] Format:@"M-d-yyyy"]] == NSOrderedAscending) // if start is later in time than end
        {
            // do something
            [surveyListsArray removeObject:_survey];
            i--;
        }
    }
    
    [surveyLists reloadData];
}

- (IBAction) selectCloseSurveyLists:(id)sender {
    toggleOpenClose = NO;
    
    [closeBtn setTitleColor:[UIColor colorWithHexString:OPEN_STATE_COLOR] forState:UIControlStateNormal];
    [openBtn setTitleColor:[UIColor colorWithHexString:CLOSE_STATE_COLOR] forState:UIControlStateNormal];
    surveyListsArray = [[NSMutableArray alloc] init];
    
    [self fetchCoreData];
    
    for (int i=0;i<[surveyListsArray count]; i++) {
        SurveyInfo *_survey = [surveyListsArray objectAtIndex:i];
        if([_survey.scheduled compare: [[Global sharedManager] getDateFromString:[[Global sharedManager] getStringFromDate:[NSDate date] Format:@"M-d-yyyy"] Format:@"M-d-yyyy"]] != NSOrderedAscending) // if start is later in time than end
        {
            // do something
            [surveyListsArray removeObject:_survey];
            i--;
        }
    }
    
    [surveyLists reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [surveyListsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SurveyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SurveyTableCell" forIndexPath:indexPath];
    if ([surveyListsArray count] > 0) {
        SurveyInfo *survey = [surveyListsArray objectAtIndex:indexPath.row];
        cell.surveyName.text = survey.sname;
        cell.surveyDesc.text = [NSString stringWithFormat:@"%@ %@ %@ %@", survey.addressline1, survey.addressline2, survey.city, [[Global sharedManager] getStateNameById:survey.state]];
        Global *global = [Global sharedManager];
        if (toggleOpenClose) {
            cell.surveyScheduled.text = [global getStringFromDate:survey.scheduled Format:@"M-d-yyyy"];
        }
        else {
            cell.surveyScheduled.text = [NSString stringWithFormat:@"Past %@", [global getStringFromDate:survey.scheduled Format:@"M-d-yyyy"]];
        }
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Global *global = [Global sharedManager];
    SurveyInfo *survey = [surveyListsArray objectAtIndex:indexPath.row];
    global.surveyID = survey.ofp_sid;
    global.surveyName = survey.sname;
    global.surveyNamePath = [global.surveyName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    DetailedSurveyViewController *detailedSurveyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailedSurveyCtrl"];
//    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeClear];
    [self.navigationController pushViewController:detailedSurveyCtrl animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickBtnLogout:(id)sender {

    Global *global = [Global sharedManager];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:global.supervisorID forKey:@"SUPERVISORID"];
    [prefs setObject:@"NO" forKey:@"IS_LOGGED_IN"];
    [prefs synchronize];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LOGOUT" object:nil]];
}

@end

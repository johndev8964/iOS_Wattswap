//
//  AppDelegate.m
//  Wattswap
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <MFSideMenu.h>
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "APIService.h"
#import "CoredataManager.h"

@import AVFoundation;

@interface AppDelegate ()
@property (assign) SystemSoundID pewPewSound;
@property (assign) SystemSoundID buttonPlusTapSound;
@property (assign) SystemSoundID buttonMinusTapSound;

@end

@implementation AppDelegate

@synthesize global;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [IQKeyboardManager sharedManager].enable = YES;
    
    // Override point for customization after application launch.
    global = [Global sharedManager];
    global.syncSurveys = [[NSMutableArray alloc] init];
    global.syncFloors = [[NSMutableArray alloc] init];
    global.syncAreas = [[NSMutableArray alloc] init];
    global.syncFixtures = [[NSMutableArray alloc] init];
    global.g_dicOthers = [NSMutableDictionary dictionary];
    
    [[APIService sharedManager] getTimeZoneDiff:^(NSDictionary *result, NSError *error) {
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSDictionary *data = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"success"]) {
                global.g_timeDiff2Server = ((NSString*)[data objectForKey:@"time_zone_diff"]).intValue;
            }
        }
    }];
    
    [self createDirectory];
    
    self.networkMonitor = [AFNetworkReachabilityManager managerForDomain:@"http://www.yahoo.com"];
    __weak AppDelegate *WeakSelf = self;
    [self.networkMonitor setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NETWORK_CONNECTED" object:nil];
            WeakSelf.global.internetConnected = YES;
            if(WeakSelf.global.isUploading == NO)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Sync2Server *syncManager = [Sync2Server sharedSyncManager];
                    [syncManager startSync2LcDB];
                });
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NETWORK_DISCONNECTED" object:nil];
            WeakSelf.global.internetConnected = NO;
        }
    }];
    [self.networkMonitor startMonitoring];
    
    
    NSString *dropBoxAppKey = @"w97du9dspfo6adj";
    NSString *dropBoxAppSecret = @"ksspyo5se35a7cs";
    NSString *root = kDBRootDropbox;
    DBSession* session =
    [[DBSession alloc] initWithAppKey:dropBoxAppKey appSecret:dropBoxAppSecret root:root];
    session.delegate = self;
    [DBSession setSharedSession:session];
    [DBRequest setNetworkRequestDelegate:self];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[global setUserInterface] bundle:nil];
    MainViewController *mainCtrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    LoginViewController *loginCtrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    MenuViewController *menuCtrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"MenuCtrl"];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    global.supervisorID = [prefs stringForKey:@"SUPERVISORID"];
    NSString *isLoggedIn = [prefs stringForKey:@"IS_LOGGED_IN"];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    if (global.supervisorID != nil && isLoggedIn != nil && [isLoggedIn isEqualToString:@"YES"]) {
        
        [self loadFixtureOptions];
        [self loadStateOptions];
        [self loadConversionList];
        
//        [self syncSurvey];
        
        global.g_sideMenu = [MFSideMenuContainerViewController
                             containerWithCenterViewController:mainCtrl
                             leftMenuViewController:menuCtrl
                             rightMenuViewController:nil];
        [global.g_sideMenu setLeftMenuWidth:([UIScreen mainScreen].bounds.size.width - 60)];
        global.g_sideMenu.panMode = MFSideMenuPanModeNone;
        [navController pushViewController:global.g_sideMenu animated:NO];
    }
    else
    {
        global.g_sideMenu = [MFSideMenuContainerViewController
                             containerWithCenterViewController:loginCtrl
                             leftMenuViewController:menuCtrl
                             rightMenuViewController:nil];
        [global.g_sideMenu setLeftMenuWidth:([UIScreen mainScreen].bounds.size.width - 60)];
        global.g_sideMenu.panMode = MFSideMenuPanModeNone;
        [navController pushViewController:global.g_sideMenu animated:NO];
    }

    NSString *pewPewPath = [[NSBundle mainBundle] pathForResource:@"censor-beep" ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);

    NSString *buttonPlusTapPath = [[NSBundle mainBundle] pathForResource:@"button-plus-tap" ofType:@"wav"];
    NSURL *buttonPlusTapURL = [NSURL fileURLWithPath:buttonPlusTapPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)buttonPlusTapURL, &_buttonPlusTapSound);
    
    NSString *buttonMinusTapPath = [[NSBundle mainBundle] pathForResource:@"button-minus-tap" ofType:@"wav"];
    NSURL *buttonMinusTapURL = [NSURL fileURLWithPath:buttonMinusTapPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)buttonMinusTapURL, &_buttonMinusTapSound);
    
    return YES;
}

- (void)playSystemSound:(BOOL)isPlusButton {
    AudioServicesPlaySystemSound(isPlusButton ? self.buttonPlusTapSound : self.buttonMinusTapSound);
}

- (void) loadFixtureOptions
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *jsonResult = [prefs objectForKey:@"FIXTURE_OPTIONS"];
    if(jsonResult != nil) global.fixtureOptions = [jsonResult objectForKey:@"data"];

    [SVProgressHUD showWithStatus:@"loading..."];
    [[APIService sharedManager] getFixtureOptions:^(NSDictionary *result, NSError *error) {
        [SVProgressHUD dismiss];
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSDictionary *optionData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"success"]) {
                global.fixtureOptions = optionData;
            }
        }
        
        if(global.internetConnected && global.fixtureOptions == nil)
            [self loadFixtureOptions];
        
        if(global.fixtureOptions != nil)
            [SVProgressHUD dismiss];
    }];
}

- (void) loadStateOptions
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *jsonResult = [prefs objectForKey:@"STATES"];
    if(jsonResult != nil) global.states = [jsonResult objectForKey:@"data"];
    
    [SVProgressHUD showWithStatus:@"loading..."];

    [[APIService sharedManager] getStates:^(NSDictionary *result2, NSError *error2) {
        if(error2 == nil) {
            NSString *statusCode2 = [result2 objectForKey:@"status"];
            NSArray *stateData = [result2 objectForKey:@"data"];
            if ([statusCode2 isEqualToString:@"Success"]) {
                global.states = stateData;
            }
        }
        
        if(global.internetConnected && global.states == nil)
            [self loadStateOptions];
        
        if(global.states != nil)
            [SVProgressHUD dismiss];
    }];
}

- (void) loadConversionList {
    
    [[APIService sharedManager] getRetrofits:^(NSDictionary *result, NSError *error) {
        if(error == nil) {
            
            NSString *statusCode = [result objectForKey:@"status"];
            NSArray *conversionData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"Success"]) {
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                
                [APIService deleteObjectFromCoreData:@"RetrofitInfo" Condition:@"retrofit_id!=%@" FieldValue:0];
                for(int i=0; i<[conversionData count]; i++) {
                    NSDictionary *conversion = [conversionData objectAtIndex:i];
                    RetrofitInfo *retrofitInfo = [NSEntityDescription insertNewObjectForEntityForName:@"RetrofitInfo" inManagedObjectContext:coreDataContext];
                    [retrofitInfo initWithDict:conversion];
                }
                [coreDataContext save:&error];
            }
        }
        
        NSArray *conversions = [APIService getObjectsFromCoreData:@"RetrofitInfo"];
        if(global.internetConnected && conversions == nil)
            [self loadConversionList];
        
        if(global.states != nil)
            [SVProgressHUD dismiss];
    }];

//    [[APIService sharedManager] getConversionList:^(NSDictionary *result, NSError *error) {
//        if(error == nil) {
//            
//            NSString *statusCode = [result objectForKey:@"status"];
//            NSArray *conversionData = [result objectForKey:@"data"];
//            if ([statusCode isEqualToString:@"Success"]) {
//                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
//                
//                [APIService deleteObjectFromCoreData:@"ConversionInfo" Condition:@"conversion_id!=%@" FieldValue:0];
//                for(int i=0; i<[conversionData count]; i++) {
//                    NSDictionary *conversion = [conversionData objectAtIndex:i];
//                    ConversionInfo *conversionInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ConversionInfo" inManagedObjectContext:coreDataContext];
//                    
//                    conversionInfo.conversion_id = NFS([conversion objectForKey:@"conversion_id"]);
//                    conversionInfo.fixture_type = [conversion objectForKey:@"fixture_type_name"];
//                    conversionInfo.fixture_code = [conversion objectForKey:@"fixture_code_name"];
//                    conversionInfo.fixture_name = [conversion objectForKey:@"conversion_fixture_name"];
//                    conversionInfo.image_path = [conversion objectForKey:@"conversion_image_path"];
//                    conversionInfo.retrofit_desc = [conversion objectForKey:@"conversion_retrofit_desc"];
//                    conversionInfo.lamp_ballast_type = [conversion objectForKey:@"conversion_lamp_ballast_type"];
//                    conversionInfo.fixture_input_watt = NFS([conversion objectForKey:@"conversion_fixture_input_watt"]);
//                }
//                [coreDataContext save:&error];
//            }
//        }
//        
//        NSArray *conversions = [APIService getObjectsFromCoreData:@"ConversionInfo"];
//        if(global.internetConnected && conversions == nil)
//            [self loadConversionList];
//        
//        if(global.states != nil)
//            [SVProgressHUD dismiss];
//    }];
}

- (void) createDirectory {
    NSString* documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES)[0];
    NSString *folder = [documentsPath stringByAppendingPathComponent:@"Wattswap"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:folder]){
        [fileManager createDirectoryAtPath:folder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    global.wattSwapDirectory = folder;
}

#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted
{
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped
{
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:nil]];
        }
        return YES;
    }
    return NO;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
    [[[UIAlertView alloc] initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
                      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil] show];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

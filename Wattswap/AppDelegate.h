//
//  AppDelegate.h
//  Wattswap
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AFNetworkReachabilityManager.h>
#import "Sync2Server.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBNetworkRequestDelegate, DBSessionDelegate, Sync2ServerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) Global   *global;
@property (retain, nonatomic) AFNetworkReachabilityManager   *networkMonitor;

- (void) loadFixtureOptions;
- (void)loadStateOptions;
- (void) loadConversionList;
- (void)playSystemSound:(BOOL)isPlusButton;

@end




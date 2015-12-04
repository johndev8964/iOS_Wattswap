//
//  MenuViewController.h
//  Wattswap
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sync2Server.h"

@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, Sync2ServerDelegate>

@property (nonatomic, retain) UINavigationController *navigationCtrl;
@property (nonatomic, retain) IBOutlet UITableView   *surveyLists;
@property (nonatomic, retain) IBOutlet UIButton      *openBtn;
@property (nonatomic, retain) IBOutlet UIButton      *closeBtn;

@property (nonatomic, retain) NSMutableArray         *surveyListsArray;
@property (nonatomic) Boolean toggleOpenClose;

@property (nonatomic, retain) UIRefreshControl      *refreshControl;

+ (id)sharedManager;

- (IBAction) addNewSurvey:(id)sender;
- (IBAction) selectOpenSurveyLists:(id)sender;
- (IBAction) selectCloseSurveyLists:(id)sender;
- (IBAction)onClickBtnSettings:(id)sender;
- (void) fetchCoreData;

@end

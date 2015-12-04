//
//  SurveyPropertyTabPageViewController.m
//  Wattswap
//
//  Created by MY on 8/16/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "SurveyPropertyTabPageViewController.h"
#import "FloorTableViewCell.h"
#import "AreaTableViewCell.h"
#import "FixtureTableViewCell.h"
#import "FloorLastTableViewCell.h"
#import "AreaLastTableViewCell.h"
#import "FixtureLastTableViewCell.h"
#import "NewFixtureViewController.h"

#import "CoredataManager.h"
#import "APIService.h"

@interface SurveyPropertyTabPageViewController () <EditableTableControllerDelegate>
{
    NSArray *m_aryPropertyTables;
    NSInteger m_selectedPropertyIndex;
    
    NSMutableArray *m_aryAreas;
    NSMutableArray *m_aryFixtures;
    
    SurveyInfo *m_curServeyInfo;
    FloorInfo *m_curFloorInfo;
    AreaInfo *m_curAreaInfo;
    FixtureInfo *m_curFixtureInfo;
}

@property (nonatomic, strong) id itemBeingMoved;

@end

@implementation SurveyPropertyTabPageViewController
@synthesize m_segmentedControl, m_tblFixture, m_tblFloor, m_tblArea;
@synthesize m_editableTableControllerForFloor, m_editableTableControllerForArea, m_editableTableControllerForFixture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_segmentedControl = [[HYSegmentedControl alloc] initWithOriginY:0 Titles:@[@"Floor", @"Area", @"Fixture"] delegate:self] ;
    [self.m_viewSegmentContainer addSubview:self.m_segmentedControl];
    
    m_selectedPropertyIndex = 0;
    m_tblFloor.tag = 0; m_tblFloor.estimatedRowHeight = 44.0f;
    m_tblArea.tag = 1; m_tblArea.estimatedRowHeight = 44.0f;
    m_tblFixture.tag = 2; m_tblFixture.estimatedRowHeight = 44.0f;
    m_aryPropertyTables = @[m_tblFloor, m_tblArea, m_tblFixture];
    
    Global *global = [Global sharedManager];
    global.floorsArray = [[NSMutableArray alloc] initWithArray:[global.floorsArray sortedArrayUsingFunction:SequenceFloorSort context:nil]];
    
    m_editableTableControllerForFloor = [[EditableTableController alloc] initWithTableView:m_tblFloor];
    m_editableTableControllerForFloor.delegate = self;
    m_editableTableControllerForArea = [[EditableTableController alloc] initWithTableView:m_tblArea];
    m_editableTableControllerForArea.delegate = self;
    m_editableTableControllerForFixture = [[EditableTableController alloc] initWithTableView:m_tblFixture];
    m_editableTableControllerForFixture.delegate = self;

    [self initView];
}

NSInteger SequenceFloorSort(id obj1, id obj2, void *reverse)
{
    return ((FloorInfo*)obj1).seq.intValue - ((FloorInfo*)obj2).seq.intValue;
}

- (NSInteger) arrangeSequenceNumber:(Class)type
{
    Global *global = [Global sharedManager];
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    NSError *error;
    BOOL isChanged = NO;
    NSInteger count = 0;
    NSString *strType = nil;
    NSMutableArray *sequencedIds = [[NSMutableArray alloc] init];
    if(type == [FloorInfo class]) {
        strType = @"Seq_Floor";
        for(int i=0; i<[global.floorsArray count]; i++) {
            FloorInfo *info = [global.floorsArray objectAtIndex:i];
            [sequencedIds addObject:info.fid];
            if(info.seq.intValue != i) {
                info.seq = [NSNumber numberWithInt:i];
                [coreDataContext save:&error];
                isChanged = YES;
            }
        }
        count = [global.floorsArray count];
    } else if(type == [AreaInfo class]) {
        strType = @"Seq_Area";
        for(int i=0; i<[m_aryAreas count]; i++) {
            AreaInfo *info = [m_aryAreas objectAtIndex:i];
            [sequencedIds addObject:info.aid];
            if(info.seq.intValue != i) {
                info.seq = [NSNumber numberWithInt:i];
                [coreDataContext save:&error];
                isChanged = YES;
            }
        }
        count = [m_aryAreas count];
    } else if(type == [FixtureInfo class]) {
        strType = @"Seq_Fixture";
        for(int i=0; i<[m_aryAreas count]; i++) {
            FixtureInfo *info = [m_aryFixtures objectAtIndex:i];
            [sequencedIds addObject:info.fixtureid];
            
            if(info.seq.intValue != i) {
                info.seq = [NSNumber numberWithInt:i];
                [coreDataContext save:&error];
                isChanged = YES;
            }
        }
        count = [m_aryFixtures count];
    }
    
    if(isChanged) {
        NSString *strValue = ((NSNumber*)[sequencedIds objectAtIndex:0]).stringValue;
        for(int i=1; i<[sequencedIds count]; i++) {
            strValue = [strValue stringByAppendingString:@","];
            strValue = [strValue stringByAppendingString:((NSNumber*)[sequencedIds objectAtIndex:i]).stringValue];
        }
        NSDictionary *params = @{@"obj_type":strType, @"value":strValue};
        [[APIService sharedManager] changeSequence2ServerForObject:params onCompletion:^(NSDictionary *result, NSError *error) {
            if (error == nil) {
                NSString *statusCode = [result objectForKey:@"status"];
                if ([statusCode isEqualToString:@"success"] == NO) {
                    [[APIService sharedManager] setObjectAsUnsync:strType Value:strValue];
                }
            } else {
                [[APIService sharedManager] setObjectAsUnsync:strType Value:strValue];
            }
        }];
    }
    
    return count;
}



- (BOOL) isMaxIndexOfTable:(UITableView*)tableView IndexPath:(NSIndexPath*)index {
    
    Global *global = [Global sharedManager];
    NSInteger row = index.row;
    if(tableView.tag == 0 && [global.floorsArray count] == row) return YES;
    if(tableView.tag == 1 && [m_aryAreas count] == row) return YES;
    if(tableView.tag == 2 && [m_aryFixtures count] == row) return YES;
    
    return NO;
}

- (void)initView {
    Global *global = [Global sharedManager];
    if(global.survey == nil) return;
    
    self.m_lblSurveyTitle.text = global.survey.sname;
    [self selectTable:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickBtnBack:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickBtnAdd:(id)sender {
    if(m_selectedPropertyIndex < 2) {
        InputSingleValueFormView *viewInputForm = [[[NSBundle mainBundle] loadNibNamed:@"InputSingleValueFormView" owner:nil options:nil] objectAtIndex:0];
        if(m_selectedPropertyIndex == 0) {
            viewInputForm.m_lblTitle.text = @"Floor Description:";
        }
        else {
            viewInputForm.m_lblTitle.text = @"Area Description:";
        }
        viewInputForm.tag = 0; // add new
        viewInputForm.delegate = self;
        [viewInputForm showForm:self.view];
    } else {
        Global *global = [Global sharedManager];
        global.isUpdate = NO;
        global.fixture = nil;
        NewFixtureViewController *newFixtureCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"NewFixtureCtrl"];
        newFixtureCtrl.m_surveyPropTabPageVC = self;
        global.fixtureTypeName = @"";
        [self.navigationController pushViewController:newFixtureCtrl animated:YES];
    }
}

- (void)didTakenValue:(NSString *)value FromView:(UIView *)view {
    
    Global *global = [Global sharedManager];
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    if(m_selectedPropertyIndex == 0) { // floor
        if(view.tag == 0) { // add new with plus button

            FloorInfo *newFloor = [NSEntityDescription insertNewObjectForEntityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
                
            newFloor.ofp_sid = global.survey.ofp_sid;
            newFloor.sid = global.survey.sid;
            
            newFloor.fid = @0;
            newFloor.ofp_fid = [global getMaxFloorValue:YES];
            newFloor.fdesc = value;
            newFloor.seq = [NSNumber numberWithInteger:[self arrangeSequenceNumber:[FloorInfo class]]];
            newFloor.stime = SERVER_TIME([NSDate date]);
            
            NSError *error;
            if(NO == [coreDataContext save:&error]) {
                [self.view makeToast:@"Failed in adding new floor. App won't work rightly."];
                return;
            }
            
            // save new data to global array
            global.floorID = newFloor.ofp_fid;
            global.floor = newFloor;
            [global.floorsArray addObject:newFloor];
            
            if(global.survey.sid.intValue != 0) {
                NSDictionary *params = @{@"survey_id":global.survey.sid, @"floor_name":value};
                [[APIService sharedManager] addFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (error == nil) {
                        NSString *statusCode = [result objectForKey:@"status"];
                        if ([statusCode isEqualToString:@"success"]) {
                            NSDictionary *floor = [[result objectForKey:@"data"] firstObject];
                            newFloor.fid = NFS([floor objectForKey:@"floor_id"]);
                            newFloor.stime = [global getDateFromString:[floor objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                            [coreDataContext save:&error];
                        }
                    }
                }];
            }
        } else if(view.tag == 1) { // edit
            global.floor.fdesc = value;
            global.floor.stime = SERVER_TIME([NSDate date]);
            
            NSError *error;
            if(![coreDataContext save:&error]){
                [self.view makeToast:@"Failed in saving floor."];
                return;
            }
            
            if(global.floor.fid.intValue != 0)
            {
                NSDictionary *params = @{@"floor_id":global.floor.fid, @"floor_name":global.floor.fdesc};
                [[APIService sharedManager] saveFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if(error == nil)
                    {
                        NSString *statusCode = [result objectForKey:@"status"];
                        if (![statusCode isEqualToString:@"success"]) {
                            [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Floor" ObjId:global.floor.ofp_fid];
                        } else {
                            NSDictionary *floor = [[result objectForKey:@"data"] firstObject];
                            global.floor.stime = [global getDateFromString:[floor objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                            [coreDataContext save:&error];
                        }
                    }
                    else
                        [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Floor" ObjId:global.floor.ofp_fid];
                }];
            }
            else
            {
                if(global.floor.sid.intValue != 0) {
                    NSDictionary *params = @{@"survey_id":global.floor.sid, @"floor_name":global.floor.fdesc};
                    [[APIService sharedManager] addFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                        [SVProgressHUD dismiss];
                        if(error == nil) {
                            NSString *statusCode = [result objectForKey:@"status"];
                            if ([statusCode isEqualToString:@"success"]) {
                                
                                NSDictionary *floor = [[result objectForKey:@"data"] firstObject];
                                global.floor.fid = NFS([floor objectForKey:@"floor_id"]);
                                global.floor.stime = [global getDateFromString:[floor objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                                
                                [coreDataContext save:&error];
                            }
                        }
                    }];
                }
            }
        }
        
        [self goAreaList];
        
    } else if(m_selectedPropertyIndex == 1) { // area
        if(view.tag == 0) { // add new with plus button
            // at first, save new data to local coredata
            AreaInfo *newArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
            
            newArea.ofp_sid = global.floor.ofp_sid;
            newArea.sid = global.floor.sid;
            
            newArea.ofp_fid = global.floor.ofp_fid;
            newArea.fid = global.floor.fid;
            
            newArea.aid = @0;
            newArea.ofp_aid = [global getMaxAreaValue:YES];
            
            newArea.adesc = value;
            newArea.seq = [NSNumber numberWithInteger:[self arrangeSequenceNumber:[AreaInfo class]]];
            newArea.stime = SERVER_TIME([NSDate date]);
            
            NSError *error;
            if(NO == [coreDataContext save:&error]) {
                [self.view makeToast:@"Failed in adding new area. App won't work rightly."];
                return;
            }
            
            // save new data to global array
            global.areaID = newArea.ofp_aid;
            global.area = newArea;
            [global.areasArray addObject:newArea];
            
            if(global.floor.fid.intValue != 0) {
                NSDictionary *params = @{@"survey_id":global.floor.sid, @"floor_id":global.floor.fid, @"area_name":value};
                [[APIService sharedManager] addArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (error == nil) {
                        NSString *statusCode = [result objectForKey:@"status"];
                        if ([statusCode isEqualToString:@"success"]) {
                            NSDictionary *area = [[result objectForKey:@"data"] firstObject];
                            newArea.aid = NFS([area objectForKey:@"area_id"]);
                            newArea.stime = [global getDateFromString:[area objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                            
                            [coreDataContext save:&error];
                        }
                    }
                }];
            }
            
            [self loadAreasOfFloor:global.floor];

        } else if(view.tag == 1) { // edit
            global.area.adesc = value;
            global.area.stime = SERVER_TIME([NSDate date]);
            
            NSError *error;
            if(![coreDataContext save:&error]){
                [self.view makeToast:error.description];
                return;
            }
            
            if(global.area.aid.intValue != 0)
            {
                NSDictionary *params = @{@"area_id":global.area.aid, @"area_name":value};
                [[APIService sharedManager] saveArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (error == nil)
                    {
                        NSString *statusCode = [result objectForKey:@"status"];
                        if (![statusCode isEqualToString:@"success"])
                        {
                            [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Area" ObjId:global.area.ofp_aid];
                        }
                        else {
                            NSDictionary *area = [[result objectForKey:@"data"] firstObject];
                            global.area.stime = [global getDateFromString:[area objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                            [coreDataContext save:&error];
                        }
                    }
                    else
                        [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Area" ObjId:global.area.ofp_aid];
                }];
            }
            else
            {
                if(global.floor.fid.intValue != 0) {
                    NSDictionary *params = @{@"survey_id":global.floor.sid, @"floor_id":global.floor.fid, @"area_name":value};
                    [[APIService sharedManager] addArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                        [SVProgressHUD dismiss];
                        if (error == nil) {
                            NSString *statusCode = [result objectForKey:@"status"];
                            if ([statusCode isEqualToString:@"success"]) {
                                NSDictionary *area = [[result objectForKey:@"data"] firstObject];
                                global.area.aid = NFS([area objectForKey:@"area_id"]);
                                global.area.stime = [global getDateFromString:[area objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                                [coreDataContext save:&error];
                            }
                        }
                    }];
                }
            }
        }

        [self goFixtureList];
    }
}

- (void)selectTable:(NSInteger)index {
    if(m_selectedPropertyIndex > index) {
        switch (index) {
            case 0:
                [m_segmentedControl setSegmentTitleAtIndex:0 Title:@"Floor"];
                [m_segmentedControl setSegmentTitleAtIndex:1 Title:@"Area"];
                break;
            case 1:
                [m_segmentedControl setSegmentTitleAtIndex:1 Title:@"Area"];
                break;
                
            default:
                break;
        }
    }
    m_selectedPropertyIndex = index;
    
    // handle show/hidden
    UITableView *selectedTableView = [m_aryPropertyTables objectAtIndex:index];
    [selectedTableView setHidden:NO];
    for( int i=0; i<[m_aryPropertyTables count]; i++) {
        if(i != index) {
            UITableView *tableView = [m_aryPropertyTables objectAtIndex:i];
            [tableView setHidden:YES];
        }
    }
    
    // display data to tableview
    [selectedTableView reloadData];
}

NSInteger SequenceAreaSort(id obj1, id obj2, void *reverse)
{
    return ((AreaInfo *)obj1).seq.intValue - ((AreaInfo*)obj2).seq.intValue;
}

- (void) loadAreasOfFloor:(FloorInfo*)floor {
    Global *global = [Global sharedManager];
    NSMutableArray *_aryAreas = [[NSMutableArray alloc] init];
    
    for (AreaInfo *area in global.areasArray) {
        if (area.ofp_fid.intValue == global.floor.ofp_fid.intValue) {
            [_aryAreas addObject:area];
        }
    }

    m_aryAreas = [[NSMutableArray alloc] initWithArray:[_aryAreas sortedArrayUsingFunction:SequenceAreaSort context:nil]];
}

NSInteger SequenceFixtureSort(id obj1, id obj2, void *reverse)
{
    return ((FixtureInfo *)obj1).seq.intValue - ((FixtureInfo*)obj2).seq.intValue;
}

- (void) loadFixturesOfArea:(AreaInfo*)area {
    Global *global = [Global sharedManager];
    NSMutableArray *_aryFixtures = [[NSMutableArray alloc] init];
    
    for (FixtureInfo *fixture in global.fixturesArray) {
        if (fixture.ofp_aid.intValue == global.area.ofp_aid.intValue) {
            [_aryFixtures addObject:fixture];
        }
    }
    
    m_aryFixtures = [[NSMutableArray alloc] initWithArray:[_aryFixtures sortedArrayUsingFunction:SequenceFixtureSort context:nil]];
}

- (void)goAreaList {
    Global *global = [Global sharedManager];
    [self loadAreasOfFloor:global.floor];
    [self selectTable:1];
    [m_segmentedControl setSegmentTitleAtIndex:0 Title:global.floor.fdesc];
    [m_segmentedControl changeSegmentedControlWithIndex:1];
}

- (void)goFixtureList {
    Global *global = [Global sharedManager];
    [self loadFixturesOfArea:global.area];
    [self selectTable:2];
    [m_segmentedControl setSegmentTitleAtIndex:1 Title:global.area.adesc];
    [m_segmentedControl changeSegmentedControlWithIndex:2];
}

#pragma mark - HYSegmentedControlDelegate
- (void)hySegmentedControlSelectAtIndex:(NSInteger)index {
    [self selectTable:index];
}

- (BOOL)hySegmentedControlEnabledSelectAtIndex:(NSInteger)index {

    if(m_selectedPropertyIndex < index) return NO;
    
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Global *global = [Global sharedManager];
    NSInteger numberOfRows = 0;
    switch(m_selectedPropertyIndex) {
        case 0: {
            numberOfRows = [global.floorsArray count];
            break;
        }
        case 1: {
            numberOfRows = [m_aryAreas count];
            break;
        }
        case 2: {
            numberOfRows = [m_aryFixtures count];
            break;
        }
        default: {
            numberOfRows = -1;
            break;
        }
    }

    numberOfRows = numberOfRows + 1;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Global *global = [Global sharedManager];
    UITableViewCell *cell = nil;
    switch (m_selectedPropertyIndex) {
        case 0: {
            if(indexPath.row == [global.floorsArray count]) {
                FloorLastTableViewCell *floorCell = [[[NSBundle mainBundle] loadNibNamed:@"FloorLastTableViewCell" owner:nil options:nil] objectAtIndex:0];
                floorCell.m_surveyPropertyTabPageVC = self;
                cell = floorCell;
            } else {
                FloorTableViewCell *floorCell = [[[NSBundle mainBundle] loadNibNamed:@"FloorTableViewCell" owner:nil options:nil] objectAtIndex:0];
                FloorInfo *floor = [global.floorsArray objectAtIndex:indexPath.row];
                floorCell.floorName.text = floor.fdesc;
                floorCell.numOfAreas.text = [NSString stringWithFormat:@"%d", [global numOfAreasInFloor:floor.ofp_fid]];
                floorCell.numOfFixtures.text = [NSString stringWithFormat:@"%d", [global numOfFixturesInFloor:floor.ofp_fid]];
                
                NSMutableArray *rightUtilityButtons = [NSMutableArray new];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"11b5e2"] title:@"Copy"];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"cccccc"] title:@"Edit"];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"dd0000"] title:@"Delete"];
                
                floorCell.rightUtilityButtons = rightUtilityButtons;
                floorCell.delegate = self;

                cell = floorCell;
            }
            break;
        }
        case 1: {
            if(indexPath.row == [m_aryAreas count]) {
                AreaLastTableViewCell *areaCell = [[[NSBundle mainBundle] loadNibNamed:@"AreaLastTableViewCell" owner:nil options:nil] objectAtIndex:0];
                areaCell.m_surveyPropertyTabPageVC = self;
                cell = areaCell;
            } else {
                AreaTableViewCell *areaCell = [[[NSBundle mainBundle] loadNibNamed:@"AreaTableViewCell" owner:nil options:nil] objectAtIndex:0];
                AreaInfo *area = [m_aryAreas objectAtIndex:indexPath.row];
                areaCell.areaName.text = area.adesc;
                areaCell.numOfFixtures.text = [NSString stringWithFormat:@"%d", [global numOfFixturesInArea:area.ofp_aid]];

                NSMutableArray *rightUtilityButtons = [NSMutableArray new];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"11b5e2"] title:@"Copy"];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"cccccc"] title:@"Edit"];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"dd0000"] title:@"Delete"];
                
                areaCell.rightUtilityButtons = rightUtilityButtons;
                areaCell.delegate = self;
                
                cell = areaCell;
            }
            break;
        }
        case 2: {
            if(indexPath.row == [m_aryFixtures count]) {
                FixtureLastTableViewCell *fixtureCell = [[[NSBundle mainBundle] loadNibNamed:@"FixtureLastTableViewCell" owner:nil options:nil] objectAtIndex:0];
                cell = fixtureCell;
            } else {
                FixtureTableViewCell *fixtureCell = [[[NSBundle mainBundle] loadNibNamed:@"FixtureTableViewCell" owner:nil options:nil] objectAtIndex:0];
                FixtureInfo *fixture = [m_aryFixtures objectAtIndex:indexPath.row];
                fixtureCell.fixtureTypeName.text = fixture.fixturetype;
                fixtureCell.fixtureCnts.text = fixture.fixturecnt;
                fixtureCell.fixtureLampCodeAndMountingType.text = [NSString stringWithFormat:@"%@, %@", fixture.lamptype, fixture.mounting];
                NSString *imgPath = fixture.ofp_path;
                if(imgPath != nil && imgPath.length > 0)
                {
                    UIImage *fixtureImage = [UIImage imageWithContentsOfFile:imgPath];
                    [fixtureCell.fixtureImage setImage:fixtureImage];
                }
                else
                {
                    imgPath = fixture.path;
                    if(imgPath != nil && imgPath.length > 0)
                    {
                        __weak FixtureTableViewCell *weakCell = fixtureCell;
                        NSURL *imageURL = [NSURL URLWithString:imgPath];
                        [fixtureCell.fixtureImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                                                     placeholderImage:nil
                                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray
                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                  weakCell.fixtureImage.image = image;
                                                                  
                                                                  fixture.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"fixture_%@.png", fixture.ofp_fixtureid] FromImage:image];
                                                                  
                                                                  NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                                                                  NSError *error;
                                                                  [coreDataContext save:&error];
                                                              }
                                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                  NSLog(@"%@", error.description);
                                                              }];
                    }
                }
                NSMutableArray *rightUtilityButtons = [NSMutableArray new];
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"dd0000"] title:@"Delete"];
                
                fixtureCell.rightUtilityButtons = rightUtilityButtons;
                fixtureCell.delegate = self;
                cell = fixtureCell;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(m_selectedPropertyIndex == 2) return 70.0f;
    return 44.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Global *global = [Global sharedManager];
    switch (m_selectedPropertyIndex) {
        case 0:
        {
            FloorLastTableViewCell *cell = (FloorLastTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[global.floorsArray count] inSection:0]];
            [cell.floorName resignFirstResponder];
            
            if(indexPath.row != [global.floorsArray count]) {
                global.floor = [global.floorsArray objectAtIndex:indexPath.row];
                
                [self goAreaList];
            }
            break;
        }
        case 1:
        {
            AreaLastTableViewCell *cell = (AreaLastTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[m_aryAreas count] inSection:0]];
            [cell.areaName resignFirstResponder];
            
            if(indexPath.row != [m_aryAreas count]) {
                global.area = [m_aryAreas objectAtIndex:indexPath.row];
                
                [self goFixtureList];
            }
            break;
        }
        case 2:
        {
            if(indexPath.row != [m_aryFixtures count]) {
                global.fixture = [m_aryFixtures objectAtIndex:indexPath.row];
                global.fixtureID = global.fixture.ofp_fixtureid;
                global.isUpdate = YES;
                NewFixtureViewController *newFixtureCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"NewFixtureCtrl"];
                newFixtureCtrl.m_surveyPropTabPageVC = self;
                [self.navigationController pushViewController:newFixtureCtrl animated:YES];

            } else {
                global.isUpdate = NO;
                global.fixture = nil;
                NewFixtureViewController *newFixtureCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"NewFixtureCtrl"];
                newFixtureCtrl.m_surveyPropTabPageVC = self;
                global.fixtureTypeName = @"";
                [self.navigationController pushViewController:newFixtureCtrl animated:YES];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {

    [cell hideUtilityButtonsAnimated:YES];

    UITableView *tableView = m_aryPropertyTables[m_selectedPropertyIndex];
    NSIndexPath *cellIndexPath = [tableView indexPathForCell:cell];
    
    if(m_selectedPropertyIndex == 0) {
        [self processRequest2FloorForOperation:index Row:cellIndexPath.row];
    } else if(m_selectedPropertyIndex == 1) {
        [self processRequest2AreaForOperation:index Row:cellIndexPath.row];
    } else {
        [self processRequest2FixtureForDeletingRow:cellIndexPath.row];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];

    if(m_selectedPropertyIndex == 0) { // floor
        if (alertView.tag == 1) { // copy
            if (buttonIndex == 1) {
                UITextField* copiedName = [alertView textFieldAtIndex:0];
                NSDictionary *params = @{@"floor_id":global.floor.fid, @"floor_name":copiedName.text};
                
                [SVProgressHUD showWithStatus:@"Copying floor..."];
                [[APIService sharedManager] copyFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    if (error == nil) {
                        NSString* statusCode = [result objectForKey:@"status"];
                        NSMutableDictionary* data = [result objectForKey:@"data"];
                        
                        if ([statusCode isEqualToString:@"success"]) {
                            FloorInfo *newFloor = [NSEntityDescription insertNewObjectForEntityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
                            NSDictionary *floorData = [[data objectForKey:@"floor"] firstObject];
                            newFloor.ofp_sid = global.floor.ofp_sid;
                            newFloor.ofp_fid = [global getMaxFloorValue:YES];
                            [newFloor initWithDict:floorData];
                            
                            [global.floorsArray addObject:newFloor];
                            global.floor = newFloor;
                            
                            NSMutableDictionary* areasForFloor = [data objectForKey:@"areas"];
                            NSMutableDictionary* aid2ofpid = [[NSMutableDictionary alloc] init];
                            for (NSDictionary* area in areasForFloor){
                                AreaInfo *newArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
                                newArea.ofp_sid = global.floor.ofp_sid;
                                newArea.ofp_fid = newFloor.ofp_fid;
                                newArea.ofp_aid = [global getMaxAreaValue:YES];
                                [newArea initWithDict:area];
                                
                                [global.areasArray addObject:newArea];
                                [aid2ofpid setObject:newArea.ofp_aid forKey:newArea.aid];
                            }
                            
                            NSMutableDictionary* fixturesForFloor = [data objectForKey:@"fixtures"];
                            for (NSDictionary *fixture in fixturesForFloor) {
                                FixtureInfo *newFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
                                
                                newFixture.ofp_sid = global.floor.ofp_sid;
                                newFixture.ofp_fid = newFloor.ofp_fid;
                                newFixture.ofp_aid = [aid2ofpid objectForKey:newFixture.aid];
                                newFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
                                [newFixture initWithDict:fixture];
                                
                                [global.fixturesArray addObject:newFixture];
                            }
                            
                            [m_tblFloor reloadData];
                            
                            NSError *error;
                            if([coreDataContext save:&error]==NO)
                            {
                                [self.view makeToast:error.description];
                            }
                        }
                        else {
                            [self copyFloor2CoreData:global.floor CopiedName:copiedName.text];
                        }
                    }
                    else {
                        [self copyFloor2CoreData:global.floor CopiedName:copiedName.text];
                    }
                    [SVProgressHUD dismiss];
                }];
            }
        }
        else {
            if (buttonIndex == 1) {
                NSNumber *ofp_floor_id = global.floor.ofp_fid;
                NSNumber *floor_id = global.floor.fid;
                [coreDataContext deleteObject:global.floor];
                [global.floorsArray removeObject:global.floor];
                
                [APIService deleteObjectFromCoreData:@"FixtureInfo" Condition:@"ofp_fid==%@" FieldValue:ofp_floor_id.stringValue];
                [APIService deleteObjectFromCoreData:@"AreaInfo" Condition:@"ofp_fid==%@" FieldValue:ofp_floor_id.stringValue];
                
                NSError *error1;
                if(NO == [coreDataContext save:&error1]) {
                    [self.view makeToast:error1.description];
                    return;
                }
                
                [m_tblFloor reloadData];
                
                if(floor_id.intValue != 0) {
                    NSDictionary *params = @{@"floor_id":floor_id};
                    [[APIService sharedManager] deleteFloorFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                        if (error == nil) {
                            NSString *statusCode = [result objectForKey:@"status"];
                            if(NO == [statusCode isEqualToString:@"Success"])
                            {
                                [[APIService sharedManager] setObjectAsUnsync:@"Del_Floor" ObjId:floor_id];
                            }
                        }
                        else {
                            [[APIService sharedManager] setObjectAsUnsync:@"Del_Floor" ObjId:floor_id];
                        }
                        [SVProgressHUD dismiss];
                    }];
                }
            }
        }
    }
    else if(m_selectedPropertyIndex == 1) { // area
        if (buttonIndex == 1) {
            if (alertView.tag == 2) {
                
                NSNumber *area_id = global.area.aid;
                NSNumber *ofp_area_id = global.area.ofp_aid;
                [APIService deleteObjectFromCoreData:@"FixtureInfo" Condition:@"ofp_aid==%@" FieldValue:ofp_area_id.stringValue];
                
                [global.areasArray removeObject:global.area];
                [coreDataContext deleteObject:global.area];
                
                NSError *error1;
                if(NO == [coreDataContext save:&error1]) {
                    [self.view makeToast:error1.description];
                    return;
                }
                
                [self loadAreasOfFloor:global.floor];
                [m_tblArea reloadData];
                
                if(area_id.intValue != 0) {
                    NSDictionary *params = @{@"area_id":area_id};
                    [[APIService sharedManager] deleteAreaFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                        if (error == nil) {
                            NSString *statusCode = [result objectForKey:@"status"];
                            if (![statusCode isEqualToString:@"Success"]) {
                                [[APIService sharedManager] setObjectAsUnsync:@"Del_Area" ObjId:area_id];
                            }
                        }
                        else {
                            [[APIService sharedManager] setObjectAsUnsync:@"Del_Area" ObjId:area_id];
                        }
                        [SVProgressHUD dismiss];
                    }];
                }
            }
            else
            {
                UITextField* copiedName = [alertView textFieldAtIndex:0];
                NSDictionary *params = @{@"area_id":global.area.aid, @"area_name":copiedName.text};
                [SVProgressHUD showWithStatus:@"Copying area..."];
                [[APIService sharedManager] copyArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    if (error == nil)
                    {
                        NSString *statusCode = [result objectForKey:@"status"];
                        NSMutableDictionary* data = [result objectForKey:@"data"];
                        
                        if ([statusCode isEqualToString:@"success"])
                        {
                            NSDictionary* areaData = [[data objectForKey:@"area"] firstObject];
                            AreaInfo *newArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
                            
                            newArea.ofp_sid = global.area.ofp_sid;
                            newArea.ofp_fid = global.area.ofp_fid;
                            newArea.ofp_aid = [global getMaxAreaValue:YES];
                            [newArea initWithDict:areaData];

                            global.area = newArea;
                            [global.areasArray addObject:newArea];
                            
                            NSMutableDictionary* fixturesForArea = [data objectForKey:@"fixtures"];
                            for (NSDictionary *fixture in fixturesForArea)
                            {
                                FixtureInfo *newFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
                                
                                newFixture.ofp_sid = global.area.ofp_sid;
                                newFixture.ofp_fid = global.area.ofp_fid;
                                newFixture.ofp_aid = newArea.ofp_aid;
                                newFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
                                [newFixture initWithDict:fixture];
                                
                                [global.fixturesArray addObject:newFixture];
                            }
                            
                            [self loadAreasOfFloor:global.floor];
                            [m_tblArea reloadData];
                            
                            NSError *error;
                            if([coreDataContext save:&error] == NO)
                            {
                                [self.view makeToast:error.description];
                            }
                        }
                        else {
                            [self copyArea2CoreData:global.area CopiedName:copiedName.text];
                        }
                    }
                    else {
                        [self copyArea2CoreData:global.area CopiedName:copiedName.text];
                    }
                    [SVProgressHUD dismiss];
                }];
            }
        }
    }
    else {
        if (buttonIndex == 1) {
            if (alertView.tag == 2) {
                
                NSNumber *fixture_id = global.fixture.fixtureid;
                [global.fixturesArray removeObject:global.fixture];
                [coreDataContext deleteObject:global.fixture];
                
                NSError *error1;
                if(NO == [coreDataContext save:&error1]) {
                    [self.view makeToast:error1.description];
                    return;
                }
                
                [self loadFixturesOfArea:global.area];
                [m_tblFixture reloadData];
                
                if(fixture_id.intValue != 0)
                {
                    NSDictionary *params = @{@"fixture_id":fixture_id};
                    [[APIService sharedManager] deleteFixtureFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                        [SVProgressHUD dismiss];
                        if (error == nil) {
                            NSString *statusCode = [result objectForKey:@"status"];
                            if (![statusCode isEqualToString:@"Success"]) {
                                [[APIService sharedManager] setObjectAsUnsync:@"Del_Fixture" ObjId:fixture_id];
                            }
                        }
                        else {
                            [[APIService sharedManager] setObjectAsUnsync:@"Del_Fixture" ObjId:fixture_id];
                        }
                    }];
                }
            }
        }
    }
}

#pragma mark - EditableTableViewDelegate

- (void)editableTableController:(EditableTableController *)controller willBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView *tableView = controller.tableView;

    if([self isMaxIndexOfTable:tableView IndexPath:indexPath])
        return;
    
    [tableView beginUpdates];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if(tableView.tag == 0) {
        Global *global = [Global sharedManager];
        self.itemBeingMoved = [global.floorsArray objectAtIndex:indexPath.row];
    } else if(tableView.tag == 1) {
        self.itemBeingMoved = [m_aryAreas objectAtIndex:indexPath.row];
    } else if(tableView.tag == 2) {
        self.itemBeingMoved = [m_aryFixtures objectAtIndex:indexPath.row];
    }
    
    [tableView endUpdates];
}

- (void)editableTableController:(EditableTableController *)controller movedCellWithInitialIndexPath:(NSIndexPath *)initialIndexPath fromAboveIndexPath:(NSIndexPath *)fromIndexPath toAboveIndexPath:(NSIndexPath *)toIndexPath
{
    UITableView *tableView = controller.tableView;
    
    if([self isMaxIndexOfTable:tableView IndexPath:fromIndexPath] || [self isMaxIndexOfTable:tableView IndexPath:toIndexPath])
        return;
    
    [tableView beginUpdates];
    [tableView moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
    
    if(tableView.tag == 0) {
        Global *global = [Global sharedManager];
        FloorInfo *item = [global.floorsArray objectAtIndex:toIndexPath.row];
        [global.floorsArray removeObjectAtIndex:toIndexPath.row];
        
        if (fromIndexPath.row == [global.floorsArray count])
        {
            [global.floorsArray addObject:item];
        }
        else
        {
            [global.floorsArray insertObject:item atIndex:fromIndexPath.row];
        }
    } else if(tableView.tag == 1) {
        AreaInfo *item = [m_aryAreas objectAtIndex:toIndexPath.row];
        [m_aryAreas removeObjectAtIndex:toIndexPath.row];
        
        if (fromIndexPath.row == [m_aryAreas count])
        {
            [m_aryAreas addObject:item];
        }
        else
        {
            [m_aryAreas insertObject:item atIndex:fromIndexPath.row];
        }
    } else if(tableView.tag == 2) {
        FixtureInfo *item = [m_aryFixtures objectAtIndex:toIndexPath.row];
        [m_aryFixtures removeObjectAtIndex:toIndexPath.row];
        
        if (fromIndexPath.row == [m_aryFixtures count])
        {
            [m_aryFixtures addObject:item];
        }
        else
        {
            [m_aryFixtures insertObject:item atIndex:fromIndexPath.row];
        }
    }
    
    [tableView endUpdates];
}

- (BOOL)editableTableController:(EditableTableController *)controller shouldMoveCellFromInitialIndexPath:(NSIndexPath *)initialIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath withSuperviewLocation:(CGPoint)location
{
    return YES;
}

- (void)editableTableController:(EditableTableController *)controller didMoveCellFromInitialIndexPath:(NSIndexPath *)initialIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(initialIndexPath.row == toIndexPath.row) return;
    
    UITableView *tableView = controller.tableView;
    if([self isMaxIndexOfTable:tableView IndexPath:initialIndexPath] || [self isMaxIndexOfTable:tableView IndexPath:toIndexPath])
        return;
    
    if(tableView.tag == 0) {
        Global *global = [Global sharedManager];
        [global.floorsArray replaceObjectAtIndex:toIndexPath.row withObject:self.itemBeingMoved];
        [self arrangeSequenceNumber:[FloorInfo class]];
    } else if(tableView.tag == 1) {
        [m_aryAreas replaceObjectAtIndex:toIndexPath.row withObject:self.itemBeingMoved];
        [self arrangeSequenceNumber:[AreaInfo class]];
    } else if(tableView.tag == 2) {
        [m_aryFixtures replaceObjectAtIndex:toIndexPath.row withObject:self.itemBeingMoved];
        [self arrangeSequenceNumber:[FixtureInfo class]];
    }

    [tableView reloadRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    self.itemBeingMoved = nil;
}

// ----------------------------------------------- swipe event handlers ----------------------------------------------
- (void) processRequest2FloorForOperation:(NSInteger)opr Row:(NSInteger)row {
    
    Global *global = [Global sharedManager];
    global.floor = [global.floorsArray objectAtIndex:row];
    global.floorID = global.floor.ofp_fid;
    if(opr == 0) // copy
    {
        UIAlertView *floorCopyAlertView = [[UIAlertView alloc] initWithTitle:@"Floor Name" message:@"Enter Floor Name:" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        floorCopyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        floorCopyAlertView.tag = 1; // copy
        [floorCopyAlertView show];
    }
    else if(opr == 1) // edit
    {
        InputSingleValueFormView *viewInputForm = [[[NSBundle mainBundle] loadNibNamed:@"InputSingleValueFormView" owner:nil options:nil] objectAtIndex:0];
        viewInputForm.delegate = self;
        viewInputForm.m_lblTitle.text = @"Floor Description:";
        viewInputForm.m_textValue.text = global.floor.fdesc;
        viewInputForm.tag = 1; // edit
        [viewInputForm showForm:self.view];
    }
    else // delete
    {
        UIAlertView *floorDeleteAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to delete this floor?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        floorDeleteAlertView.tag = 2; // delete
        [floorDeleteAlertView show];
    }
}

- (void) processRequest2AreaForOperation:(NSInteger)opr Row:(NSInteger)row {
    
    Global *global = [Global sharedManager];
    global.area = [m_aryAreas objectAtIndex:row];
    global.areaID = global.area.ofp_aid;
    if(opr == 0) // copy
    {
        UIAlertView *areaCopyAlertView = [[UIAlertView alloc] initWithTitle:@"Area Name" message:@"Enter Area Name:" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        areaCopyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        areaCopyAlertView.tag = 1; // copy
        [areaCopyAlertView show];
    }
    else if(opr == 1) // edit
    {
        InputSingleValueFormView *viewInputForm = [[[NSBundle mainBundle] loadNibNamed:@"InputSingleValueFormView" owner:nil options:nil] objectAtIndex:0];
        viewInputForm.delegate = self;
        viewInputForm.m_lblTitle.text = @"Area Description:";
        viewInputForm.m_textValue.text = global.area.adesc;
        viewInputForm.tag = 1; // edit
        [viewInputForm showForm:self.view];
    }
    else // delete
    {
        UIAlertView *areaDeleteAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to delete this area?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        areaDeleteAlertView.tag = 2; // delete
        [areaDeleteAlertView show];
    }
}

- (void)processRequest2FixtureForDeletingRow:(NSInteger)row {
    
    Global *global = [Global sharedManager];
    global.fixture = [m_aryFixtures objectAtIndex:row];
    global.fixtureID = global.fixture.ofp_fixtureid;
    
    UIAlertView *fixtureDeleteAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to delete this fixture?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    fixtureDeleteAlertView.tag = 2; // delete
    [fixtureDeleteAlertView show];
}

- (void)copyFloor2CoreData:(FloorInfo*)floorInfo CopiedName:(NSString*)copiedName
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    
    FloorInfo *copiedFloor = [NSEntityDescription insertNewObjectForEntityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
    copiedFloor.sid = floorInfo.sid;
    copiedFloor.ofp_sid = floorInfo.ofp_sid;
    copiedFloor.fid = @0;
    copiedFloor.ofp_fid = [global getMaxFloorValue:YES];
    copiedFloor.fdesc = copiedName;
    copiedFloor.stime = SERVER_TIME([NSDate date]);
    NSError *error;
    if([coreDataContext save:&error]) {
        [global.floorsArray addObject:copiedFloor];
    }
    else
    {
        [self.view makeToast:error.description];
        return;
    }
    
    NSArray *aryArea = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"ofp_fid" IDValue:floorInfo.ofp_fid.stringValue];
    if(aryArea != nil) {
        for(int i=0; i<[aryArea count]; i++) {
            AreaInfo *area = (AreaInfo*)[aryArea objectAtIndex:i];
            AreaInfo *copiedArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
            copiedArea.sid = area.sid;
            copiedArea.ofp_sid = area.ofp_sid;
            copiedArea.fid = @0;
            copiedArea.ofp_fid = copiedFloor.ofp_fid;
            copiedArea.aid = @0;
            copiedArea.ofp_aid = [global getMaxAreaValue:YES];
            copiedArea.adesc = area.adesc;
            copiedArea.stime = SERVER_TIME([NSDate date]);
            
            if([coreDataContext save:&error])
            {
                [global.areasArray addObject:copiedArea];
            }
            else
            {
                [self.view makeToast:error.description];
                return;
            }
            
            NSArray *aryFixture = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"ofp_aid" IDValue:area.ofp_aid.stringValue];
            if(aryFixture != nil) {
                for(int j=0; j<[aryFixture count]; j++) {
                    FixtureInfo *fixture = (FixtureInfo*)[aryFixture objectAtIndex:j];
                    FixtureInfo *copiedFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
                    copiedFixture.sid = fixture.sid;
                    copiedFixture.ofp_sid = fixture.ofp_sid;
                    copiedFixture.fid = @0;
                    copiedFixture.ofp_fid = copiedArea.ofp_fid;
                    copiedFixture.aid = @0;
                    copiedFixture.ofp_aid = copiedArea.ofp_aid;
                    copiedFixture.fixtureid = @0;
                    copiedFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
                    
                    copiedFixture.supervisor_id = fixture.supervisor_id;
                    copiedFixture.hoursperweek = fixture.hoursperweek;
                    copiedFixture.hoursinyear = fixture.hoursinyear;
                    copiedFixture.ballastfactor = fixture.ballastfactor;
                    copiedFixture.ballasttype = fixture.ballasttype;
                    copiedFixture.bulbsperfixture = fixture.bulbsperfixture;
                    copiedFixture.lampcode = fixture.lampcode;
                    copiedFixture.control = fixture.control;
                    copiedFixture.fixturecnt = fixture.fixturecnt;
                    copiedFixture.fixturetype = fixture.fixturetype;
                    copiedFixture.hoursperday = fixture.hoursperday;
                    copiedFixture.height = fixture.height;
                    copiedFixture.mounting = fixture.mounting;
                    copiedFixture.note = fixture.note;
                    copiedFixture.option = fixture.option;
                    copiedFixture.path = fixture.path;
                    copiedFixture.style = fixture.style;
                    copiedFixture.daysperweek = fixture.daysperweek;
                    copiedFixture.wattsperbulb = fixture.wattsperbulb;
                    copiedFixture.ofp_path = fixture.ofp_path;
                    copiedFixture.replacement_id = fixture.replacement_id;
                    copiedFixture.stime = SERVER_TIME([NSDate date]);
                    
                    if([coreDataContext save:&error]) {
                        [global.fixturesArray addObject:copiedFixture];
                    }
                    else
                    {
                        [self.view makeToast:error.description];
                        return;
                    }
                }
            }
        }
        
        [m_tblFloor reloadData];
    }
}

- (void)copyArea2CoreData:(AreaInfo*)areaInfo CopiedName:(NSString*)copiedName
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    
    AreaInfo *copiedArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
    copiedArea.sid = areaInfo.sid;
    copiedArea.ofp_sid = areaInfo.ofp_sid;
    copiedArea.fid = areaInfo.fid;
    copiedArea.ofp_fid = areaInfo.ofp_fid;
    copiedArea.aid = @0;
    copiedArea.ofp_aid = [global getMaxAreaValue:YES];
    copiedArea.adesc = copiedName;
    copiedArea.stime = SERVER_TIME([NSDate date]);
    
    NSError *error;
    if([coreDataContext save:&error])
    {
        [global.areasArray addObject:copiedArea];
    }
    else {
        [self.view makeToast:error.description];
        return;
    }
    
    NSArray *aryFixture = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"ofp_aid" IDValue:areaInfo.ofp_aid.stringValue];
    if(aryFixture != nil) {
        for(int j=0; j<[aryFixture count]; j++) {
            FixtureInfo *fixture = (FixtureInfo*)[aryFixture objectAtIndex:j];
            FixtureInfo *copiedFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
            copiedFixture.sid = fixture.sid;
            copiedFixture.ofp_sid = fixture.ofp_sid;
            copiedFixture.fid = fixture.fid;
            copiedFixture.ofp_fid = fixture.ofp_fid;
            copiedFixture.aid = @0;
            copiedFixture.ofp_aid = copiedArea.ofp_aid;
            copiedFixture.fixtureid = @0;
            copiedFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
            
            copiedFixture.supervisor_id = fixture.supervisor_id;
            copiedFixture.hoursperweek = fixture.hoursperweek;
            copiedFixture.hoursinyear = fixture.hoursinyear;
            copiedFixture.ballastfactor = fixture.ballastfactor;
            copiedFixture.ballasttype = fixture.ballasttype;
            copiedFixture.bulbsperfixture = fixture.bulbsperfixture;
            copiedFixture.lampcode = fixture.lampcode;
            copiedFixture.control = fixture.control;
            copiedFixture.fixturecnt = fixture.fixturecnt;
            copiedFixture.fixturetype = fixture.fixturetype;
            copiedFixture.hoursperday = fixture.hoursperday;
            copiedFixture.height = fixture.height;
            copiedFixture.mounting = fixture.mounting;
            copiedFixture.note = fixture.note;
            copiedFixture.option = fixture.option;
            copiedFixture.path = fixture.path;
            copiedFixture.style = fixture.style;
            copiedFixture.daysperweek = fixture.daysperweek;
            copiedFixture.wattsperbulb = fixture.wattsperbulb;
            copiedFixture.ofp_path = fixture.ofp_path;
            copiedFixture.replacement_id = fixture.replacement_id;
            copiedFixture.stime = SERVER_TIME([NSDate date]);
            
            if([coreDataContext save:&error])
            {
                [global.fixturesArray addObject:copiedFixture];
            }
            else {
                [self.view makeToast:error.description];
                return;
            }
        }
    }
    
    [self loadAreasOfFloor:global.floor];
    [m_tblArea reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    if(m_selectedPropertyIndex == 2)
        [self selectTable:m_selectedPropertyIndex];
}

@end

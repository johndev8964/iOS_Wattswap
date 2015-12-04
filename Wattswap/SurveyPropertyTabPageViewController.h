//
//  SurveyPropertyTabPageViewController.h
//  Wattswap
//
//  Created by MY on 8/16/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputSingleValueFormView.h"
#import "EditableTableController.h"

@interface SurveyPropertyTabPageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, HYSegmentedControlDelegate, SWTableViewCellDelegate, InputSingleValueInputFormViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *m_viewSegmentContainer;
@property (strong, nonatomic) IBOutlet UIButton *m_btnBack;
@property (strong, nonatomic) IBOutlet UILabel *m_lblSurveyTitle;
@property (strong, nonatomic) IBOutlet UIButton *m_btnAddNewProperty;

@property (retain, nonatomic) HYSegmentedControl *m_segmentedControl;

@property (strong, nonatomic) IBOutlet UITableView *m_tblFloor;
@property (strong, nonatomic) IBOutlet UITableView *m_tblArea;
@property (strong, nonatomic) IBOutlet UITableView *m_tblFixture;

@property (nonatomic, strong) EditableTableController *m_editableTableControllerForFloor;
@property (nonatomic, strong) EditableTableController *m_editableTableControllerForArea;
@property (nonatomic, strong) EditableTableController *m_editableTableControllerForFixture;

- (void)goAreaList;
- (void)goFixtureList;
- (void)loadAreasOfFloor:(FloorInfo*)floor;
- (void)loadFixturesOfArea:(AreaInfo*)area;
- (NSInteger) arrangeSequenceNumber:(Class)type;

@end

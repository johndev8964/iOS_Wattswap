//
//  FloorLastTableViewCell.h
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurveyPropertyTabPageViewController.h"

@interface FloorLastTableViewCell : SWTableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *floorName;
@property (weak, nonatomic) IBOutlet UIView *addFloorView;

@property (nonatomic, retain) Global *global;
@property (nonatomic, retain) SurveyPropertyTabPageViewController * m_surveyPropertyTabPageVC;
@property (strong, nonatomic) IBOutlet UIButton *m_btnSave;

- (IBAction) saveFloor:(id)sender;

@end

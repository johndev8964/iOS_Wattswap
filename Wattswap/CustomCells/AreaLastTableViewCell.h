//
//  AreaLastTableViewCell.h
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"
#import "SurveyPropertyTabPageViewController.h"

@interface AreaLastTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *areaName;
@property (weak, nonatomic) IBOutlet UIView *addAreaView;
@property (strong, nonatomic) IBOutlet UIButton *m_btnSave;

@property (nonatomic, retain) Global *global;
@property (nonatomic, retain) SurveyPropertyTabPageViewController * m_surveyPropertyTabPageVC;

- (IBAction) saveArea:(id)sender;

@end

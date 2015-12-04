//
//  NewSurveyViewController.h
//  Wattswap
//
//  Created by User on 5/13/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurveyInfo.h"
#import "ActionSheetDatePicker.h"

@interface NewSurveyViewController : UIViewController <UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton     *cancelBtn;
@property (nonatomic, retain) IBOutlet UIButton     *saveBtn;
@property (nonatomic, retain) IBOutlet UIButton     *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel        *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *viewContentOfScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthOfView;
@property (weak, nonatomic) IBOutlet UIPickerView *statePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UITextField *facilityName;
@property (weak, nonatomic) IBOutlet UITextField *facilityAddress1;
@property (weak, nonatomic) IBOutlet UITextField *facilityAddress2;
@property (weak, nonatomic) IBOutlet UITextField *facilityCity;
@property (weak, nonatomic) IBOutlet UITextField *facilityState;
@property (weak, nonatomic) IBOutlet UITextField *facilityZip;
@property (weak, nonatomic) IBOutlet UITextField *contactName;
@property (weak, nonatomic) IBOutlet UITextField *contactPhone;
@property (weak, nonatomic) IBOutlet UITextField *contactEmail;
@property (weak, nonatomic) IBOutlet UITextField *contactScheduled;
@property (weak, nonatomic) IBOutlet UITextField *contactNote;
@property (weak, nonatomic) IBOutlet UITextField *buildingUnits;
@property (weak, nonatomic) IBOutlet UITextField *buildingType;
@property (weak, nonatomic) IBOutlet UITextField *buildingRefer;
@property (weak, nonatomic) IBOutlet UITextField *buildingFootage;
@property (weak, nonatomic) IBOutlet UITextField *buildingCompany;
@property (weak, nonatomic) IBOutlet UITextField *buildingAccountNumber;
@property (nonatomic, retain) IBOutlet UIButton *facilityImageLoad;
@property (weak, nonatomic) IBOutlet UIImageView *surveyImageView;
@property (weak, nonatomic) IBOutlet UIButton *removeImageBtn;

@property (strong, nonatomic) IBOutlet UITextField *surveyRatePerWatt;

@property (nonatomic, retain) Global         *global;
@property (nonatomic, retain) UIAlertView    *cancelAlert;
@property (nonatomic, retain) UIAlertView    *deleteAlert;
@property (nonatomic, retain) NSMutableArray *m_stateNames;
@property (nonatomic, strong) ActionSheetDatePicker *m_scheduledDatePicker;

- (IBAction) cancel:(id)sender;
- (IBAction) save:(id)sender;
- (IBAction) loadSurveyImage:(id)sender;
- (IBAction) deleteSurveyImage:(id)sender;
- (IBAction) deleteSurvey:(id)sender;

@end

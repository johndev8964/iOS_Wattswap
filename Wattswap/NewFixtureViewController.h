//
//  NewFixtureViewController.h
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionTableFormView.h"
#import "SurveyPropertyTabPageViewController.h"
#import "DetailedFixtureViewController.h"

@interface NewFixtureViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OptionTableFormViewDelegate, DetailedFixtureViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFloorAreaName;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *m_lblSurveyName;
@property (weak, nonatomic) IBOutlet UIButton *fixtureImageBtn;
@property (weak, nonatomic) IBOutlet UITextField *m_txtFixtureCnt;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFixtureCntMinus;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFixtureCntPlus;

@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureSize;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureType;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLense;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureControlled;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureMounting;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureHeight;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLampType;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLampCode;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLamp;
@property (weak, nonatomic) IBOutlet UILabel *m_lblReplacementLampDesc;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureStyle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureOption;
@property (weak, nonatomic) IBOutlet UILabel *m_lblHoursPerWeek;
@property (weak, nonatomic) IBOutlet UITextField *m_txtHoursPerWeek;
@property (weak, nonatomic) IBOutlet UILabel *m_lblHoursPerYear;
@property (weak, nonatomic) IBOutlet UITextField *m_txtHoursPerDay;
@property (weak, nonatomic) IBOutlet UITextField *m_txtDaysPerWeek;
@property (weak, nonatomic) IBOutlet UITextView *m_textViewFixtureNotes;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureBallastType;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureBallastFactor;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFixtureWatts;
@property (weak, nonatomic) IBOutlet UITextField *m_txtLampCount;
@property (weak, nonatomic) IBOutlet UITextField *m_txtLampWatts;

@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureSize;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureType;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddLense;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureControlled;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureMounting;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureHeight;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddLampType;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddLampCode;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddLamp;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddReplacementLamp;

@property (weak, nonatomic) IBOutlet UIButton *m_btnDetailedFixture;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddBallastType;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddBallastFactor;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureStyle;
@property (weak, nonatomic) IBOutlet UIButton *m_btnAddFixtureOption;
@property (weak, nonatomic) IBOutlet UIButton *m_btnDeleteFixture;

@property (nonatomic, retain) Global *global;
@property (nonatomic, retain) NSString *fixtureTypeStr;
@property (nonatomic) int selectedIndex;
@property (nonatomic, retain) NSString *selectedText;

@property (nonatomic, retain) UIImage  *fixtureImage;

@property (nonatomic, retain) NSArray *fixtureSizeList;
@property (nonatomic, retain) NSArray *fixtureTypeList;
@property (nonatomic, retain) NSArray *lenseList;
@property (nonatomic, retain) NSArray *fixtureControlledList;
@property (nonatomic, retain) NSArray *fixtureMountingList;
@property (nonatomic, retain) NSArray *fixtureHeightList;
@property (nonatomic, retain) NSArray *lampTypeList;
@property (nonatomic, retain) NSArray *lampCodeList;
@property (nonatomic, retain) NSArray *lampList;
@property (nonatomic, retain) NSArray *realLampWattageList;
@property (nonatomic, retain) NSArray *lampWatts;
@property (nonatomic, retain) NSArray *fixtureBallastTypeList;
@property (nonatomic, retain) NSArray *fixtureBallastFactorList;
@property (nonatomic, retain) NSArray *fixtureStyleList;
@property (nonatomic, retain) NSArray *fixtureOptionList;

@property (nonatomic, readwrite) int replacement_id;
@property (nonatomic, retain) NSMutableArray *checkList;
@property (nonatomic, retain) UIAlertView *deleteAlert;
@property (nonatomic, retain) SurveyPropertyTabPageViewController *m_surveyPropTabPageVC;
@property (nonatomic, retain) RetrofitInfo *m_selectedRetrofit;


@property (strong, nonatomic) IBOutlet UIImageView *fixtureImageView;

- (IBAction) goMenu:(id)sender;
- (IBAction) saveNewFixture:(id)sender;
- (IBAction) goBack:(id)sender;
- (IBAction) loadFixtureImage:(id)sender;
- (IBAction) fixtureCntPlusMinus:(id)sender;
- (IBAction) showAddView:(id)sender;
- (IBAction) goDetailedFixture:(id)sender;
- (IBAction) deleteFixture:(id)sender;

@end

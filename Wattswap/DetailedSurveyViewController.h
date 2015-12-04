//
//  DetailedSurveyViewController.h
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurveyInfo.h"
#import <MessageUI/MessageUI.h>

@interface DetailedSurveyViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *surveyTitle;
@property (weak, nonatomic) IBOutlet UILabel *surveyName;
@property (weak, nonatomic) IBOutlet UILabel *surveyAddress;
@property (weak, nonatomic) IBOutlet UILabel *surveyScheduledDate;
@property (weak, nonatomic) IBOutlet UILabel *surveyContactName;
@property (weak, nonatomic) IBOutlet UILabel *surveyContactPhone;
@property (weak, nonatomic) IBOutlet UILabel *surveyContactEmail;
@property (weak, nonatomic) IBOutlet UILabel *numOfFloors;
@property (weak, nonatomic) IBOutlet UILabel *numOfAreas;
@property (weak, nonatomic) IBOutlet UILabel *numOfFixtures;
@property (weak, nonatomic) IBOutlet UILabel *numOfFixtureCounts;
@property (weak, nonatomic) IBOutlet UIImageView *emailCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *facilityImage;

@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;

@property (nonatomic, retain) Global *global;
@property (nonatomic) int fixtureCounts;
@property (nonatomic) BOOL  mustGoAddFloor;


- (IBAction) goMap:(id)sender;
- (IBAction) startSurvey:(id)sender;
- (IBAction) emailCheck:(id)sender;
- (IBAction) importFacilityImage:(id)sender;
- (IBAction) previewHtml:(id)sender;
- (IBAction) emailSurvey:(id)sender;
- (IBAction) goMenu:(id)sender;
- (IBAction) editSurvey:(id)sender;

@end

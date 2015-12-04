//
//  NewSurveyViewController.m
//  Wattswap
//
//  Created by User on 5/13/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "NewSurveyViewController.h"
#import "Constants.h"
#import "APIService.h"
#import "AppDelegate.h"
#import "SurveyInfo.h"
#import "CoredataManager.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface NewSurveyViewController ()

@property (strong, atomic) ALAssetsLibrary *library;

@end

@implementation NewSurveyViewController

@synthesize scrollView, cancelBtn, saveBtn, datePickerView, contactScheduled, facilityState, statePickerView, surveyImageView;
@synthesize facilityName, facilityAddress1, facilityAddress2, facilityCity, facilityImageLoad, facilityZip, contactName, contactEmail, contactNote, contactPhone, buildingAccountNumber, buildingCompany, buildingFootage, buildingRefer, buildingType, buildingUnits, deleteBtn, titleLabel, removeImageBtn, surveyRatePerWatt;
@synthesize global, cancelAlert, deleteAlert, library;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [cancelBtn setTitleColor:[UIColor colorWithHexString:OPEN_STATE_COLOR] forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor colorWithHexString:OPEN_STATE_COLOR] forState:UIControlStateNormal];
    
    self.library = [[ALAssetsLibrary alloc] init];
    
    CGFloat fWidth = [[UIScreen mainScreen] bounds].size.width;
    self.widthOfView.constant = fWidth;

    global = [Global sharedManager];
    if (global.isUpdate)
    {
        titleLabel.text = global.survey.sname;
        facilityName.text = global.survey.sname;
        facilityAddress1.text = global.survey.addressline1;
        facilityAddress2.text = global.survey.addressline2;
        facilityCity.text = global.survey.city;
        facilityState.text = [global getStateNameById:global.survey.state];
        facilityZip.text = global.survey.zip;
        contactName.text = global.survey.cname;
        contactEmail.text = global.survey.cemail;
        contactPhone.text = global.survey.cphone;
        contactNote.text = global.survey.note;
        contactScheduled.text = [global getStringFromDate:global.survey.scheduled Format:@"M-d-yyyy"];
        buildingAccountNumber.text = global.survey.accountnumber;
        buildingCompany.text = global.survey.butilitycompany;
        buildingFootage.text = global.survey.btototalfutage;
        buildingRefer.text = global.survey.breff;
        buildingType.text = global.survey.btype;
        buildingUnits.text = global.survey.bunit;
        surveyRatePerWatt.text = [NSString stringWithFormat:@"%.3f", global.survey.rateperwatt.floatValue];
        surveyRatePerWatt.text = [NSNumber numberWithFloat:surveyRatePerWatt.text.floatValue].stringValue;

        NSString *imgPath = global.survey.ofp_path;
        if(imgPath != nil && [imgPath isEqualToString:@""] == NO)
        {
            NSURL *imageURL = [NSURL fileURLWithPath:imgPath];
            [self.surveyImageView setImageWithURL:imageURL placeholderImage:nil];
            removeImageBtn.hidden = NO;
            facilityImageLoad.hidden = YES;
        }
        else
        {
            imgPath = global.survey.path;
            if(imgPath != nil && [imgPath isEqualToString:@""] == NO)
            {
                __weak NewSurveyViewController *weakSelf = self;
                NSURL *imageURL = [NSURL URLWithString:imgPath];
                [self.surveyImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                                                     placeholderImage:nil
                                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite
                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                  removeImageBtn.hidden = NO;
                                                                  facilityImageLoad.hidden = YES;
                                                                  weakSelf.surveyImageView.image = image;
                                                                  
                                                                  global.survey.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"survey_%@.png", weakSelf.global.survey.ofp_sid] FromImage:image];
                                                                  NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                                                                  NSError *error;
                                                                  [coreDataContext save:&error];
                                                             }
                                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                  NSLog(@"%@", error.description);
                                                              }];
            }
        }
        
        deleteBtn.hidden = NO;
    }
    else
    {
        facilityState.text = @"Florida";

        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"M-d-yyyy"]; // from here u can change format..
        NSString *stringFromDate = [df stringFromDate:[NSDate date]];
        contactScheduled.text = stringFromDate;
    }

    self.m_stateNames = [[NSMutableArray alloc] init];
    for (int i = 0;i < [global.states count];i++) {
        [self.m_stateNames addObject:[[global.states objectAtIndex:i] objectForKey:@"state_name"]];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    CGRect rectView = self.viewContentOfScrollView.frame;
    scrollView.contentSize = CGSizeMake(rectView.size.width, rectView.size.height * 1.05);
}

- (IBAction) cancel:(id)sender {
    cancelAlert = [[UIAlertView alloc] initWithTitle:nil message:@"No changes will be save!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [cancelAlert show];
}

- (IBAction) save:(id)sender {
    
    if(global.isUpdate) {
        [self saveSurvey];
    } else {
        [self addNewSurvey];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        if (alertView == deleteAlert) {
            if(alertView.tag == 0) {
                if (global.isUpdate) {
                    
                    NSNumber *ofp_surveyId = global.survey.ofp_sid;
                    NSNumber *surveyId = global.survey.sid;

                    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                    [coreDataContext deleteObject:global.survey];
                    
                    [APIService deleteObjectFromCoreData:@"FixtureInfo" Condition:@"ofp_sid==%@" FieldValue:ofp_surveyId.stringValue];
                    [APIService deleteObjectFromCoreData:@"AreaInfo" Condition:@"ofp_sid==%@" FieldValue:ofp_surveyId.stringValue];
                    [APIService deleteObjectFromCoreData:@"FloorInfo" Condition:@"ofp_sid==%@" FieldValue:ofp_surveyId.stringValue];
                    
                    NSError *error1;
                    if(NO == [coreDataContext save:&error1]) {
                        [self.view makeToast:error1.description];
                        return;
                    }
                    
                    global.survey = nil;
                    if(surveyId.intValue == 0) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        return;
                    }
                    
                    NSDictionary *params = @{@"survey_id":surveyId};
                    [SVProgressHUD showWithStatus:@"Deleting..."];
                    [[APIService sharedManager] deleteSurveyFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                        [SVProgressHUD dismiss];
                        if (error) {
                            [[APIService sharedManager] setObjectAsUnsync:@"Del_Survey" ObjId:surveyId];
                        }
                        else
                        {
                            NSString *statusCode = [result objectForKey:@"status"];
                            if (NO==[statusCode isEqualToString:@"Success"]) {
                                [[APIService sharedManager] setObjectAsUnsync:@"Del_Survey" ObjId:surveyId];
                            }
                        }
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }
            }
            else if(deleteAlert.tag == 1) {
                
                surveyImageView.image = nil;
                removeImageBtn.hidden = YES;
                facilityImageLoad.hidden = NO;

            }
        }
        else {
            global.isUpdate = false;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

# pragma mark - Date select
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"]; // from here u can change format..
    NSString *stringFromDate = [df stringFromDate:selectedDate];
    self.contactScheduled.text = stringFromDate;
    [self.contactScheduled resignFirstResponder];
}

- (void) cancelDateSelect:(id) sender
{
    // Dismiss the keyboard when the actionsheet close.
    [contactScheduled resignFirstResponder];
    
}

# pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == facilityState)
    {
        ActionSheetStringPicker *actionSheet = nil;
        
        actionSheet = [[ActionSheetStringPicker alloc] initWithTitle:@"State" rows:self.m_stateNames
                                                    initialSelection:[global getStateIndexByName:textField.text]
                                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                               
                                                               textField.text = [self.m_stateNames objectAtIndex:selectedIndex];
                                                               [textField resignFirstResponder];
                                                               
                                                           } cancelBlock:^(ActionSheetStringPicker *picker) {
                                                               
                                                               [textField resignFirstResponder];
                                                           } origin:textField pickerFontSize:[UIFont fontWithName:@"Century Gothic" size:14]];
        [actionSheet showActionSheetPicker];
    }
    else if(textField == contactScheduled) {
        // to show date picker
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M-d-yyyy"];
        NSDate *aDate = [dateFormatter dateFromString:textField.text];
        
        self.m_scheduledDatePicker  = [[ActionSheetDatePicker alloc] initWithTitle:@"Scheduled"
                                                       datePickerMode:UIDatePickerModeDate
                                                         selectedDate:aDate
                                                               target:self
                                                               action:@selector(dateWasSelected:element:)
                                                               origin:textField
                                                         cancelAction:@selector(cancelDateSelect:)];
        [self.m_scheduledDatePicker showActionSheetPicker];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// tell the picker how many rows are available for a given component
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [global.states count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dic = [global.states objectAtIndex:row];
    return [NSString stringWithFormat:@"%@",[dic objectForKey:@"state_name"]];
}

- (IBAction) loadSurveyImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take from camera" otherButtonTitles:@"Select from gallery", nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction) deleteSurvey:(id)sender {
    deleteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you'd like to delete this survey?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    deleteAlert.tag = 0;
    [deleteAlert show];
    removeImageBtn.hidden = YES;
    facilityImageLoad.hidden = NO;
}

- (IBAction) deleteSurveyImage:(id)sender {
    deleteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you'd like to delete this survey image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    deleteAlert.tag = 1;
    [deleteAlert show];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)
    {
        if (([UIImagePickerController isSourceTypeAvailable:
              
              UIImagePickerControllerSourceTypeCamera] == NO)) {
            [self.view makeToast:@"This device doesn't support camera."];
            return;
        }
        
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        imagePicker.mediaTypes =
        
        [UIImagePickerController availableMediaTypesForSourceType:
         
         UIImagePickerControllerSourceTypeCamera];
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Allow editing of image ?
        imagePicker.allowsEditing = YES;
        
        // Show image picker
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex == 1)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.allowsEditing=YES;
        imagePicker.delegate=self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex == 2)
    {
        NSLog(@"Update Button Clicked");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    surveyImageView.image = [Global croppedImage:img];
    if (img != nil) {
        removeImageBtn.hidden = NO;
        facilityImageLoad.hidden = YES;
    }
}

- (void) saveSurvey {
    if ([facilityName requiredText]) {
        NSString *stateId = nil;
        for (int i = 0;i < [global.states count];i++) {
            if ([[[global.states objectAtIndex:i] objectForKey:@"state_name"] isEqualToString:facilityState.text]) {
                stateId = [[global.states objectAtIndex:i] objectForKey:@"state_id"];
            }
        }
        
        NSData *data = UIImageJPEGRepresentation(surveyImageView.image, 0.4f);
        NSString *base64Image = @"";
        if (data != nil) {
            base64Image = [data base64EncodedString];
            
            if (surveyImageView.image != nil) {
                removeImageBtn.hidden = NO;
                facilityImageLoad.hidden = YES;
                
                [library saveImage:surveyImageView.image toAlbum:facilityName.text withCompletionBlock:^(NSError *error) {
                    if (error!=nil) {
                        NSLog(@"Error in saving image like as : %@", [error description]);
                    }
                }];
            }

        }
        
        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
        SurveyInfo *surveyInfo = global.survey;
        surveyInfo.sname = facilityName.text;
        surveyInfo.addressline1 = facilityAddress1.text;
        surveyInfo.addressline2 = facilityAddress2.text;
        surveyInfo.city = facilityCity.text;
        surveyInfo.state = stateId;
        surveyInfo.zip = facilityZip.text;
        surveyInfo.cname = contactName.text;
        surveyInfo.cphone = contactPhone.text;
        surveyInfo.cemail = contactEmail.text;
        surveyInfo.scheduled = [global getDateFromString: contactScheduled.text Format:@"M-d-yyyy"];
        surveyInfo.note = contactNote.text;
        surveyInfo.bunit = buildingUnits.text;
        surveyInfo.btype = buildingType.text;
        surveyInfo.breff = buildingRefer.text;
        surveyInfo.btototalfutage = buildingFootage.text;
        surveyInfo.butilitycompany = buildingCompany.text;
        surveyInfo.accountnumber = buildingAccountNumber.text;
        surveyInfo.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"survey_%@.png", surveyInfo.ofp_sid] FromImage:surveyImageView.image];
        surveyInfo.rateperwatt = [NSString stringWithFormat:@"%.3f", surveyRatePerWatt.text.floatValue];
        surveyInfo.rateperwatt = [NSNumber numberWithFloat:surveyInfo.rateperwatt.floatValue].stringValue;
        surveyInfo.stime = SERVER_TIME([NSDate date]);
        
        NSError *error;
        
        if(![coreDataContext save:&error]){
            [self.view makeToast:error.description];
            return;
        }
        global.survey = surveyInfo;
        global.surveyName = surveyInfo.sname;
    
        if(surveyInfo.sid.intValue != 0)
        {
            NSDictionary *params = @{@"survey_id":surveyInfo.sid, @"survey_facility_name":surveyInfo.sname,@"survey_facility_add_l1":surveyInfo.addressline1,@"survey_facility_add_l2":surveyInfo.addressline2, @"survey_facility_city":surveyInfo.city, @"state_id":surveyInfo.state,@"survey_facility_zip":surveyInfo.zip,@"survey_contact_name":surveyInfo.cname,@"survey_contact_phone":surveyInfo.cphone, @"survey_contact_email":surveyInfo.cemail,@"survey_schedule_date":[global getStringFromDate:surveyInfo.scheduled Format:@"yyyy-MM-dd"], @"survey_note":surveyInfo.note,@"survey_building_units":surveyInfo.bunit,@"survey_building_type":surveyInfo.btype,@"survey_reffered_by":surveyInfo.breff,@"survey_sq_foot":surveyInfo.btototalfutage,@"survey_utility_company":surveyInfo.butilitycompany,@"survey_account_no":surveyInfo.accountnumber, @"survey_images_b64":base64Image, @"survey_rate_per_watt":surveyInfo.rateperwatt};
            
            [[APIService sharedManager] saveSurvey2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                if(error == nil)
                {
                    NSString *statusCode = [result objectForKey:@"status"];
                    NSArray* arrayData = [result objectForKey:@"data"];
                    NSDictionary *data = arrayData[0];
                    
                    if ([statusCode isEqualToString:@"success"])
                    {
                        surveyInfo.path = ISNull([data objectForKey:@"survey_image_path"]) ? @"":[data objectForKey:@"survey_image_path"];
                        surveyInfo.stime = [global getDateFromString:[data objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                        
                        [coreDataContext save:&error];
                    }
                    else
                        [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Survey" ObjId:global.floor.ofp_fid];
                }
                else
                    [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Survey" ObjId:global.floor.ofp_fid];
            }];
        }
        else
        {
            NSDictionary *params = @{@"survey_id":surveyInfo.sid, @"survey_facility_name":surveyInfo.sname,@"survey_facility_add_l1":surveyInfo.addressline1,@"survey_facility_add_l2":surveyInfo.addressline2, @"survey_facility_city":surveyInfo.city, @"state_id":surveyInfo.state,@"survey_facility_zip":surveyInfo.zip,@"survey_contact_name":surveyInfo.cname,@"survey_contact_phone":surveyInfo.cphone, @"survey_contact_email":surveyInfo.cemail,@"survey_schedule_date":[global getStringFromDate:surveyInfo.scheduled Format:@"yyyy-MM-dd"], @"survey_note":surveyInfo.note,@"survey_building_units":surveyInfo.bunit,@"survey_building_type":surveyInfo.btype,@"survey_reffered_by":surveyInfo.breff,@"survey_sq_foot":surveyInfo.btototalfutage,@"survey_utility_company":surveyInfo.butilitycompany,@"survey_account_no":surveyInfo.accountnumber, @"survey_images_b64":base64Image, @"survey_rate_per_watt":surveyInfo.rateperwatt};
            
            [[APIService sharedManager] addSurvey2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                if(error == nil)
                {
                    NSString *statusCode = [result objectForKey:@"status"];
                    NSArray* arrayData = [result objectForKey:@"data"];
                    NSDictionary *data = arrayData[0];
                    
                    if ([statusCode isEqualToString:@"Success"])
                    {
                        surveyInfo.sid = NFS([data objectForKey:@"survey_id"]);
                        surveyInfo.path = ISNull([data objectForKey:@"survey_image_path"]) ? @"":[data objectForKey:@"survey_image_path"];
                        surveyInfo.stime = [global getDateFromString:[data objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
         
                        [coreDataContext save:&error];
                    }
                }
            }];
        }
        
        [self.navigationController popViewControllerAnimated:YES];;
    }
    else {
        [self.view makeToast:@"Please enter facility name."];
    }
}

- (void) addNewSurvey {
    if ([facilityName requiredText]) {
        
        NSString *stateId = nil;
        for (int i = 0;i < [global.states count];i++) {
            if ([[[global.states objectAtIndex:i] objectForKey:@"state_name"] isEqualToString:facilityState.text]) {
                stateId = [[global.states objectAtIndex:i] objectForKey:@"state_id"];
            }
        }
        
        // at first, save the data to core data
        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
        SurveyInfo *surveyInfo = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyInfo" inManagedObjectContext:coreDataContext];
        
        surveyInfo.sid = @0;
        surveyInfo.ofp_sid = [global getMaxSurveyValue:YES];
        surveyInfo.supervisor_id = global.supervisorID;
        surveyInfo.sname = facilityName.text;
        surveyInfo.addressline1 = facilityAddress1.text;
        surveyInfo.addressline2 = facilityAddress2.text;
        surveyInfo.city = facilityCity.text;
        surveyInfo.state = stateId;
        surveyInfo.zip = facilityZip.text;
        surveyInfo.cname = contactName.text;
        surveyInfo.cphone = contactPhone.text;
        surveyInfo.cemail = contactEmail.text;
        surveyInfo.scheduled = [global getDateFromString: contactScheduled.text Format:@"M-d-yyyy"];
        surveyInfo.note = contactNote.text;
        surveyInfo.bunit = buildingUnits.text;
        surveyInfo.btype = buildingType.text;
        surveyInfo.breff = buildingRefer.text;
        surveyInfo.btototalfutage = buildingFootage.text;
        surveyInfo.butilitycompany = buildingCompany.text;
        surveyInfo.accountnumber = buildingAccountNumber.text;
        NSString *strRateOfWatt = surveyRatePerWatt.text;
        if(strRateOfWatt.length == 0) strRateOfWatt = @"0";
        float rate = strRateOfWatt.floatValue;
        strRateOfWatt = [NSString stringWithFormat:@"%.3f", rate];
        strRateOfWatt = [NSNumber numberWithFloat:strRateOfWatt.floatValue].stringValue;
        
        surveyInfo.rateperwatt = strRateOfWatt;
        surveyInfo.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"survey_%@.png", surveyInfo.ofp_sid] FromImage:surveyImageView.image];
        surveyInfo.stime = SERVER_TIME([NSDate date]);

        if(surveyImageView.image != nil) {
            [library saveImage:surveyImageView.image toAlbum:facilityName.text withCompletionBlock:^(NSError *error) {
                if (error!=nil) {
                    NSLog(@"Error in saving image like as : %@", [error description]);
                }
            }];
        }
        
        NSError *error;
        if(NO == [coreDataContext save:&error]) {
            [self.view makeToast:@"Failed in adding new survery. App won't work rightly."];
            return;
        }

        // and then
        NSData *data = UIImageJPEGRepresentation(surveyImageView.image, 0.4f);
        NSString *base64Image = @"";
        if (data != nil) {
            base64Image = [data base64EncodedString];
        }
        
        NSDictionary *params = @{ @"supervisor_id":global.supervisorID, @"survey_facility_name":facilityName.text, @"survey_facility_add_l1":facilityAddress1.text, @"survey_facility_add_l2":facilityAddress2.text, @"survey_facility_city":facilityCity.text, @"state_id":stateId, @"survey_facility_zip":facilityZip.text, @"survey_contact_name":contactName.text, @"survey_contact_phone":contactPhone.text, @"survey_contact_email":contactEmail.text, @"survey_schedule_date":[global getUTCDate:contactScheduled.text], @"survey_note":contactNote.text, @"survey_building_units":buildingUnits.text, @"survey_building_type":buildingType.text, @"survey_reffered_by":buildingRefer.text, @"survey_sq_foot":buildingFootage.text, @"survey_utility_company":buildingCompany.text, @"survey_account_no":buildingAccountNumber.text, @"survey_images_b64":base64Image,@"survey_rate_per_watt":strRateOfWatt};
        
        [[APIService sharedManager] addSurvey2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
            [SVProgressHUD dismiss];
            if(error == nil)
            {
                NSString *statusCode = [result objectForKey:@"status"];
                NSArray* arrayData = [result objectForKey:@"data"];
                
                if ([statusCode isEqualToString:@"Success"])
                {
                    NSDictionary *data = arrayData[0];
                    surveyInfo.sid = NFS([data objectForKey:@"survey_id"]);
                    surveyInfo.path = ISNull([data objectForKey:@"survey_image_path"]) ? @"":[data objectForKey:@"survey_image_path"];
                    surveyInfo.stime = [global getDateFromString:[data objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];

                    [coreDataContext save:&error];
                }
            }
            
            global.survey = surveyInfo;
        }];

        global.survey = surveyInfo;
        [self.navigationController popViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSH_NEWSERVEY" object:nil];
    }
    else {
        [self.view makeToast:@"Please enter facility name."];
    }
}

- (void)viewDidUnload
{
    self.library = nil;
    [super viewDidUnload];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

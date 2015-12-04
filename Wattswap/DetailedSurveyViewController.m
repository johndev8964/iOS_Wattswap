//
//  DetailedSurveyViewController.m
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "DetailedSurveyViewController.h"
#import "SurveyMapViewController.h"
#import "PreviewHtmlViewController.h"
#import "MenuViewController.h"
#import "NewSurveyViewController.h"
#import "CoredataManager.h"
#import "APIService.h"
#import "SurveyPropertyTabPageViewController.h"

extern NSInteger SequenceFloorSort(id obj1, id obj2, void *reverse);
extern NSInteger SequenceAreaSort(id obj1, id obj2, void *reverse);
extern NSInteger SequenceFixtureSort(id obj1, id obj2, void *reverse);

@interface DetailedSurveyViewController ()

@end

@implementation DetailedSurveyViewController

@synthesize scrollView, surveyTitle, surveyName, surveyAddress, surveyScheduledDate, surveyContactEmail, surveyContactName, surveyContactPhone, numOfFixtures, numOfAreas, numOfFixtureCounts, numOfFloors, emailCheckImageView, facilityImage;

@synthesize global, fixtureCounts;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 600);

    global = [Global sharedManager];
    
    [SVProgressHUD dismiss];
}

- (void)initView
{
    fixtureCounts = 0;
    surveyTitle.text = global.surveyName;
    surveyName.text = global.surveyName;
    
    global.survey = [self fetchFromCoreData:global.surveyID.stringValue];
    
    surveyAddress.text = [NSString stringWithFormat:@"%@ %@ %@ %@", global.survey.addressline1, global.survey.addressline2, global.survey.city, [global getStateNameById:global.survey.state]];
    surveyScheduledDate.text = [global getStringFromDate:global.survey.scheduled Format:@"M-d-yyyy"];
    surveyContactName.text = global.survey.cname;
    surveyContactPhone.text = global.survey.cphone;
    surveyContactEmail.text = global.survey.cemail;
    
    numOfFloors.text = [NSString stringWithFormat:@"%d", [self fetchFloorsCountFromCoreData:global.surveyID.stringValue]];
    numOfAreas.text = [NSString stringWithFormat:@"%d", [self fetchAreasCountFromCoreData:global.surveyID.stringValue]];
    numOfFixtures.text = [NSString stringWithFormat:@"%d", [self fetchFixturesCountFromCoreData:global.surveyID.stringValue]];
    numOfFixtureCounts.text = [NSString stringWithFormat:@"%d", fixtureCounts];

    if(global.survey.path != nil && global.survey.path.length > 0)
    {
        if(global.survey.ofp_path.length > 0) {
            UIImage *img = [UIImage imageWithContentsOfFile:global.survey.ofp_path];
            
            facilityImage.image = img;
        }
        else {
            NSURL *imageURL = [NSURL URLWithString:global.survey.path];
            
            [self.facilityImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                                      placeholderImage:nil
                           usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   self.facilityImage.image = image;
                                                   
                                                   global.survey.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"survey_%@.png", global.survey.ofp_sid] FromImage:image];
                                                   global.imgName = global.survey.ofp_path;
                                                   NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                                                   NSError *error;
                                                   [coreDataContext save:&error];
                                                   
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   NSLog(@"%@", error.description);
                                               }];
            
            [self.takePhotoButton setBackgroundImage:nil forState:UIControlStateNormal];
            [self.takePhotoButton setTitle:@"Remove image" forState:UIControlStateNormal];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [self initView];
    if(self.mustGoAddFloor) {
        self.mustGoAddFloor = NO;
        [self startSurvey:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SurveyInfo *) fetchFromCoreData : (NSString *) sid {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SurveyInfo" inManagedObjectContext:coreDataContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ofp_sid==%@", sid]];
    
    NSError *error;
    NSArray *array = [coreDataContext executeFetchRequest:request error:&error];
    
    if([array count] > 0)
        return [array objectAtIndex:0];
    else
        return nil;
}

- (int) fetchFloorsCountFromCoreData : (NSString *) sid {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ofp_sid==%@", sid]];
    
    NSError *error;
    NSArray *array = [coreDataContext executeFetchRequest:request error:&error];
    
    global.floorsArray = [[NSMutableArray alloc] init];
    
    for (FloorInfo *floorInfo in array) {
        [global.floorsArray addObject:floorInfo];
    }
    
    return (int) [array count];
}

- (int) fetchAreasCountFromCoreData : (NSString *) sid {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ofp_sid==%@", sid]];
    
    NSError *error;
    NSArray *array = [coreDataContext executeFetchRequest:request error:&error];
    
    global.areasArray = [[NSMutableArray alloc] init];
    
    for (AreaInfo *areaInfo in array) {
        [global.areasArray addObject:areaInfo];
    }
    
    return (int) [array count];
}

- (int) fetchFixturesCountFromCoreData : (NSString *) sid {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ofp_sid==%@", sid]];
    
    NSError *error;
    NSArray *array = [coreDataContext executeFetchRequest:request error:&error];
    global.fixturesArray = [[NSMutableArray alloc] init];
    
    for (FixtureInfo *fixtureInfo in array) {
        [global.fixturesArray addObject:fixtureInfo];
        fixtureCounts += [fixtureInfo.fixturecnt intValue];
    }
    
    return (int) [array count];
}

- (IBAction) goMap:(id)sender {
    SurveyMapViewController *mapSurveyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SurveyMapCtrl"];
    mapSurveyCtrl.location = surveyAddress.text;
    [self.navigationController pushViewController:mapSurveyCtrl animated:YES];

}

- (IBAction) startSurvey:(id)sender {
    SurveyPropertyTabPageViewController *surveyPropertyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SurveyPropertyTabPageViewController"];
    [self.navigationController pushViewController:surveyPropertyVC animated:YES];
}

- (IBAction) emailCheck:(id)sender {
    NSData *imageViewImageData = UIImageJPEGRepresentation(emailCheckImageView.image, 0.7f);
    
    UIImage *checkedImage = [UIImage imageNamed:@"checked"];
    NSData *checkedImageData = UIImageJPEGRepresentation(checkedImage, 0.7f);
    
    UIImage *uncheckedImage = [UIImage imageNamed:@"unchecked"];
    
    if (![imageViewImageData isEqualToData:checkedImageData]) {
        [emailCheckImageView setImage:checkedImage];
        emailCheckImageView.tag = 1;
    }
    else {
        [emailCheckImageView setImage:uncheckedImage];
        emailCheckImageView.tag = 0;
    }
}

- (IBAction) importFacilityImage:(id)sender {
    if(facilityImage.image != nil) {
        [facilityImage setImage:nil];
        UIImage * buttonImage = [UIImage imageNamed:@"icon_camera.png"];
        [_takePhotoButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [_takePhotoButton setTitle:nil forState:UIControlStateNormal];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take from camera" otherButtonTitles:@"Select from gallery", nil];
        
        [actionSheet showInView:self.view];
    }
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
        imagePicker.allowsEditing = NO;
        
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
    
    NSString *currentMiliSecs = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *imageName = [NSString stringWithFormat:@"%@_%@_%@.jpeg", surveyName.text, global.survey.sid, currentMiliSecs];
    global.imgName = imageName;
    NSString *path = [[[Global sharedManager] wattSwapDirectory] stringByAppendingPathComponent: imageName];
    
    NSData* data = UIImageJPEGRepresentation(img, 0.4f);
    [data writeToFile:path atomically:YES];
    
    facilityImage.image = img;
    [_takePhotoButton setBackgroundImage:nil forState:UIControlStateNormal];
    [_takePhotoButton setTitle:@"Remove Images" forState:UIControlStateNormal];
}

- (IBAction) previewHtml:(id)sender {
    if ([self getSurveyStringTemplet:global.surveyID.stringValue] != nil) {
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[global setUserInterface] bundle:nil];
        PreviewHtmlViewController *previewHtmlCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewHtmlCtrl"];
        previewHtmlCtrl.htmlString = [self getSurveyStringTemplet:global.surveyID.stringValue];
        [self.navigationController pushViewController:previewHtmlCtrl animated:YES];
    }
}

- (IBAction) emailSurvey:(id)sender {
    //email subject
    NSString * subject = [NSString stringWithFormat:@"Survey report: %@ Address: %@", surveyName.text, surveyAddress.text];
    //email body
    if([self getSurveyStringTemplet:global.surveyID.stringValue] == nil) {
        [self.view makeToast:@"Can't send mail owing to an unknown error."];
        return;
    }
    //recipient(s)
    //NSArray * recipients = [NSArray arrayWithObjects:@"contact@androidiostutorials.com", nil];
    
    //create the MFMailComposeViewController
    MFMailComposeViewController * composer = [[MFMailComposeViewController alloc] init];
    composer.mailComposeDelegate = self;
    [composer setSubject:subject];
    //[composer setMessageBody:body isHTML:YES]; //if you want to send an HTML message
    //[composer setToRecipients:recipients];
    
    //get the filepath from resources
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
    
    //read the file using NSData
    //NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    // Set the MIME type
    /*you can use :
     - @"application/msword" for MS Word
     - @"application/vnd.ms-powerpoint" for PowerPoint
     - @"text/html" for HTML file
     - @"application/pdf" for PDF document
     - @"image/jpeg" for JPEG/JPG images
     */
    //NSString *mimeType = @"image/png";
    
    //add attachement
    // insert image with image/jpeg
//    if(emailCheckImageView.tag == 1) {
//        NSData *imageData = [NSData dataWithContentsOfFile:global.survey.ofp_path];
//        if(imageData != nil) {
//            [composer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"survey-%d", global.survey.ofp_sid.intValue]];
//        }
//        NSArray *aryFixtureInfos = [APIService getObjectsFromCoreData:@"FixtureInfo" Where:[NSString stringWithFormat:@"ofp_sid == %@", global.survey.ofp_sid.stringValue]];
//        for(int i=0; i<[aryFixtureInfos count]; i++) {
//            FixtureInfo *fixtureInfo = [aryFixtureInfos objectAtIndex:i];
//            NSData *imageData = [NSData dataWithContentsOfFile:fixtureInfo.ofp_path];
//            if(imageData != nil)
//                [composer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"fixture-%d", fixtureInfo.ofp_fixtureid.intValue]];
//        }
//    }
    
    // attach csv and html files
    NSData *csvData = [NSData dataWithContentsOfFile:global.csvURI];
    NSString *csvFileName = [NSString stringWithFormat:@"%@_%@.csv", global.surveyName, global.surveyID];
    [composer addAttachmentData:csvData mimeType:@"text/csv" fileName:csvFileName];
    
    // Attach html data to the email
    NSData *htmlData = [NSData dataWithContentsOfFile:global.htmlURI];
    NSString *htmlFileName = [NSString stringWithFormat:@"%@_%@.html", global.surveyName, global.surveyID];
    [composer addAttachmentData:htmlData mimeType:@"text/html" fileName:htmlFileName];

    [composer setMessageBody:global.surveyEmail isHTML:YES];
    
    //present it on the screen
    [self presentViewController:composer animated:YES completion:NULL];
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled"); break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved"); break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent"); break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]); break;
        default:
            break;
    }
    
    // close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction) goMenu:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) editSurvey:(id)sender {

    global.isUpdate = YES;
    NewSurveyViewController *newSurveyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"NewSurveyCtrl"];
    [self.navigationController pushViewController:newSurveyCtrl animated:YES];
}

- (NSString *) getSurveyStringTemplet : (NSString *) sid {

    global.htmlURI = @"";
    global.csvURI = @"";
    
    NSString *htmlFormat = @"";
    NSString *csvFormat = @"";
    NSString *bodyString = @"";

// consider with lamp code, daily hours
//    NSString *csvColumn = @"\"Building Name\",\"Address\",\"Building Dropbox Image\",\"Floor\",\"Location\",\"FIXTURE COUNT\",\"SIZE\",\"FIXTURE Type\",\"LENS\",\"CONTROLLED\",\"MOUNTING TYPE\",\"MOUNTING HEIGHT\",\"LAMP TYPE\",\"CODE\",\"LAMP\",\"REAL LAMP WATTAGE\",\"LAMP COUNT\",\"WATTS\",\"BALLAST\",\"BALLAST FACTOR\",\"STYLE\",\"OPTIONS\",\"HOURS x DAYS x WEEKS\",\"HOURS x WEEKS</th>\",\"NOTES\",\"RETROFIT DESCRIPTION\",\"LAMP\",\"BALLAST\",\"REAL LAMP WATTAGE\"\n";
    
    
    NSString *csvColumn = @"\"Building Name\",\"Address\",\"Building Dropbox Image\",\"Floor\",\"Location\",\"FIXTURE COUNT\",\"SIZE\",\"FIXTURE Type\",\"LENS\",\"CONTROLLED\",\"MOUNTING TYPE\",\"MOUNTING HEIGHT\",\"LAMP TYPE\",\"LAMP\",\"REAL LAMP WATTAGE\",\"LAMP COUNT\",\"WATTS\",\"BALLAST\",\"BALLAST FACTOR\",\"STYLE\",\"OPTIONS\",\"HOURS x WEEKS</th>\",\"NOTES\",\"RETROFIT DESCRIPTION\",\"LAMP\",\"BALLAST\",\"REAL LAMP WATTAGE\"\n";
    csvFormat = [csvFormat stringByAppendingString:csvColumn];
    
    NSString *htmlHeader = @"<!DOCTYPE html><html><body><table align=\"left\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"font-family: Helvetica,Arial,sans-serif; width: 100%; height: 100%; background: #e6e6e6; color: #5e5e5e; border-collapse: separate; border: 0; margin: 0px; padding: 20px 0px 20px 0px;\"><tbody style=\"vertical-align: top;\">";
    htmlFormat = [htmlFormat stringByAppendingString:htmlHeader];
    
    NSString *bodyHeader = @"<!DOCTYPE html><html><body><table align=\"left\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"font-family: Helvetica,Arial,sans-serif; width: 100%; height: 100%; border-collapse: separate; border: 0; margin: 0px; padding: 20px 0px 20px 0px;\"><tbody style=\"vertical-align: top;\">";
    bodyString = [bodyString stringByAppendingString:bodyHeader];
    
    if (global.survey != nil) {
        NSString *templateName = global.surveyName;
        NSString *addrDesc = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", global.survey.addressline1, global.survey.addressline2, global.survey.city, [global getStateNameById:global.survey.state], global.survey.zip];
    
        htmlFormat = [htmlFormat stringByAppendingString:@"<tr height=\"200\" style=\"height: 200px;\"><td colspan=\"1\" border=\"0\">&nbsp;</td><td colspan=\"1\" border=\"0\" width=\"20\" style=\"width: 20px\">&nbsp;</td><td colspan=\"1\" border=\"0\" width=\"700\" style=\"width: 700px;\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 100%; border-collapse: separate; border: 0; margin: 0px; padding: 0px 0px 30px 0px;\"><tbody><tr height=\"180\" style=\"height: 180px; vertical-align: top;\"><td colspan=\"1\" border=\"0\" width=\"550\" style=\"width: 550px; padding: 35px 0px 0px 10px;\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 100%; border-collapse: separate; border: 0; margin: 0px; padding: 0px 0px 0px 0px;\"><tbody><tr><td> <span style=\"text-decoration: none; color: #2f2f36; font-weight: bold; font-size: 38px; line-height: 44px;\">"];
        htmlFormat = [htmlFormat stringByAppendingString:templateName];
        htmlFormat = [htmlFormat stringByAppendingString:@"</span></td></tr><tr><br><td style=\"padding: 0px 0px 0px 3px;\"><span style=\"text-decoration: none; color: #a0a0a5; font-weight: normal; font-size: 16px; line-height: 24px;\">"];
        htmlFormat = [htmlFormat stringByAppendingString:addrDesc];
    
        bodyString = [bodyString stringByAppendingString:@"<tr><td><h2>"];
        bodyString = [bodyString stringByAppendingString:templateName];
        bodyString = [bodyString stringByAppendingString:@"</h2></td></tr><tr><td style=\"padding: 0px 0px 0px 3px;\"><span style=\"text-decoration: none; font-weight: normal; font-size: 16px; line-height: 24px;\">"];
        bodyString = [bodyString stringByAppendingString:addrDesc];
    
        htmlFormat = [htmlFormat stringByAppendingString:@"</td></tr></tbody></table></td></tr>"];
        bodyString = [bodyString stringByAppendingString:@"</span></td></tr>"];
    
        NSString *dropboxLink = @"";
        
        global.floorsArray = [NSMutableArray arrayWithArray:[global.floorsArray sortedArrayUsingFunction:SequenceFloorSort context:nil]];
        
        if ([global.floorsArray count] > 0) {
            for (FloorInfo *floor in global.floorsArray) {
                htmlFormat = [htmlFormat stringByAppendingString:@"<tr style=\"vertical-align: top;\"><td colspan=\"2\" border=\"0\" style=\"padding: 5px 0px 0px 0px;\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 100%; height: 100%; border-collapse: separate; border: 0; margin: 0px; padding: 5px; background-color: #fafafa;\"><tbody><tr height=\"32\" style=\"height: 42px; color: #fff; background-color: #00bfff;\"><br><td colspan=\"1\" width=\"80\" style=\"font-size: 18px; padding: 0px 0px 0px 10px;\">FLOOR:</td><td colspan=\"1\" style=\"font-size: 18px; padding: 0px 0px 0px 10px;\"><span>&nbsp;&nbsp;"];
                htmlFormat = [htmlFormat stringByAppendingString:floor.fdesc];
                htmlFormat = [htmlFormat stringByAppendingString:@"</td></tr>"];
                NSArray *areasArray = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"fid" IDValue:floor.fid.stringValue];
                if ([areasArray count] > 0) {
                    
                    areasArray = [NSMutableArray arrayWithArray:[areasArray sortedArrayUsingFunction:SequenceAreaSort context:nil]];
                    for (AreaInfo *area in areasArray) {
                        htmlFormat = [htmlFormat stringByAppendingString:@" <tr><td colspan=\"2\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"color: #aaadb4; width: 100%; height: 100%; border-collapse: separate; border: 0; margin: 0px; padding: 0px; background-color: #fafafa; padding: 0px 0px 10px 0px;\"><tbody><tr height=\"32\" style=\"height: 32px;\"><br><td colspan=\"1\" width=\"80\" style=\"padding: 0px 0px 0px 10px;\">AREA:</td><td colspan=\"1\" style=\"color: deepskyblue; padding: 0px 0px 0px 10px;\"><span>&nbsp;&nbsp;"];
                        htmlFormat = [htmlFormat stringByAppendingString:area.adesc];
                        htmlFormat = [htmlFormat stringByAppendingString:@"</span></td></tr>"];

                        NSArray *fixturesArray = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"aid" IDValue:area.aid.stringValue];
                        if ([fixturesArray count] > 0) {
                            
                            htmlFormat = [htmlFormat stringByAppendingString:@"<br><tr><td colspan=\"2\" style=\"border-top: 1px solid #aaadb4;\"><table align=\"left\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"font-weight: normal; font-size: 10px; line-height: 16px; width: 100%; height: 100%; border-collapse: separate; border: 0; margin: 0px; padding: 0px; background-color: #f1f1f1;\"><thead align=\"left\" style=\"background-color: #e5e5e5; color: #5e5e5e;\"><tr> \
                                          <th style=\"padding: 0px 0px 0px 5px;\">&nbsp;<nobr>FIXTURE COUNT</th> \
                                          <th style=\"padding: 0px 0px 0px 5px;\">&nbsp;&nbsp;&nbsp;SIZE&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;<nobr>FIXTURE TYPE</nobr>&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LENS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;CONTROLLED</th> \
                                          <th>&nbsp;&nbsp;&nbsp;<nobr>MOUNTING TYPE</th> \
                                          <th>&nbsp;&nbsp;&nbsp;<nobr>MOUNTING HEIGHT</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<nobr>LAMP TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <!-- th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CODE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th --> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LAMP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;<nobr>REAL LAMP WATTAGE</th> \
                                          <th>&nbsp;&nbsp;&nbsp;<nobr>LAMP COUNT</th> \
                                          <th>&nbsp;&nbsp;&nbsp;WATTS&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;BALLAST</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;<nobr>BALLAST FACTOR</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;STYLE</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;OPTIONS</th> \
                                          <!-- th>&nbsp;&nbsp;&nbsp;&nbsp;<nobr>HOURS x DAYS x WEEKS</th --> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;<nobr>HOURS x WEEKS</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NOTES&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<nobr>RETROFIT DESCRIPTION&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LAMP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BALLAST&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th> \
                                          <th>&nbsp;&nbsp;&nbsp;&nbsp;<nobr>REAL LAMP WATTAGE</th> \
                                          <th>&nbsp;</th></tr></thead><tbody style=\"color: #5e5e5e;\">"];
                            
                            fixturesArray = [NSMutableArray arrayWithArray:[fixturesArray sortedArrayUsingFunction:SequenceFixtureSort context:nil]];
                            for (FixtureInfo *fixture in fixturesArray) {
                    
                                NSString *rep_desc = @"";
                                NSString *rep_lamp = @"";
                                NSString *rep_ballast = @"";
                                NSString *rep_real_watts = @"";
                                
                                if(fixture.replacement_id.intValue != 0) {
                                    NSArray *reps = [APIService getObjectsFromCoreData:@"RetrofitInfo" IDName:@"retrofit_id" IDValue:fixture.replacement_id.stringValue];
                                    if(reps != nil && [reps count] > 0) {
                                        RetrofitInfo *rep = [reps objectAtIndex:0];
                                        rep_desc = rep.retrofit_description;
                                        rep_lamp = rep.retrofit_lamp;
                                        rep_ballast = rep.retrofit_ballast;
                                        rep_real_watts = rep.retrofit_real_lamp_wattage;
                                    }
                                }
                                
                                // FIXTURE COUNT	SIZE	FIXTURE TYPE	LENSE	CONTROLLED	MOUNTING TYPE	MOUNTING HEIGHT	LAMP TYPE	CODE	LAMP	REAL LAMP WATTAGE	LAMP COUNT	WATTS	BALLAST	BALLAST FACTOR	STYLE	OPTIONS	HOURS DAYS x WEEKS	HOURS x WEEK	NOTES	Retrofit Description	Lamp	Ballast	Real Lamp Wattage
                                NSString *row = [NSString stringWithFormat:@"<br><tr><td style=\"text-align:center; padding: 0px 0px 0px 5px;\">%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <!-- td style='text-align:center'>%@</td --> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <!-- td style='text-align:center'>&nbsp;&nbsp;&nbsp;&nbsp;%@ (%@ * %@ * 52)</td --> \
                                                 <td style='text-align:center'>&nbsp;&nbsp;&nbsp;&nbsp;%@ (%@ * 52)</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td style='text-align:center'>%@</td> \
                                                 <td>&nbsp;</td></tr>"
                                                 , fixture.fixturecnt, fixture.fixturesize, fixture.fixturetype
                                                 , fixture.lense, fixture.control, fixture.mounting, fixture.height, fixture.lamptype
                                                 , fixture.lampcode, fixture.lamp, fixture.realwatts
                                                 , fixture.bulbsperfixture, fixture.wattsperbulb, fixture.ballasttype, fixture.ballastfactor, fixture.style, fixture.option
                                                 , fixture.hoursinyear, fixture.hoursperday, fixture.daysperweek
                                                 , fixture.hoursinyear, fixture.hoursperweek
                                                 , fixture.note, rep_desc, rep_lamp, rep_ballast, rep_real_watts];
                                
                                htmlFormat = [htmlFormat stringByAppendingString:row];
                    
//                                csvColumn = @"\"Building Name\",\"Address\",\"Building Dropbox Image\",\"Floor\",\"Location\",\
                                \"FIXTURE COUNT\",\"SIZE\",\"FIXTURE Type\",\"LENS\",\"CONTROLLED\",\"MOUNTING TYPE\",\"MOUNTING HEIGHT\",\"LAMP TYPE\",\"CODE\",\"LAMP\",\"REAL LAMP WATTAGE\",\"LAMP COUNT\",\"WATTS\",\"BALLAST\",\"BALLAST FACTOR\",\"STYLE\",\"OPTIONS\",\"HOURS x DAYS x WEEKS\",\"HOURS x WEEKS</th>\",\"NOTES\",\"RETROFIT DESCRIPTION\",\"LAMP\",\"BALLAST\",\"REAL LAMP WATTAGE\"\n";

                                // consider with lamp code and daily hours
//                                NSString *csvRow = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"      ,\"%@ (%@ x %@ x 52) \",\"%@ (%@ x 52) \",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\" \n",
                                
                                NSString *csvRow = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@ (%@ x 52) \",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\" \n", [[templateName uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[addrDesc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[dropboxLink uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [floor.fdesc stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[area.adesc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    
                                                    , [[fixture.fixturecnt uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.fixturesize uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.fixturetype uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.lense uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.control uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.mounting uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [fixture.height stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.lamptype uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
//                                                    , [[fixture.lampcode uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.lamp uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.realwatts uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.bulbsperfixture uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.wattsperbulb uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.ballasttype uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.ballastfactor uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.style uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.option uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    
//                                                    , [[fixture.hoursinyear uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
//                                                    , [[fixture.hoursperday uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
//                                                    , [[fixture.daysperweek uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.hoursinyear uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[fixture.hoursperweek uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    
                                                    , [[fixture.note uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[rep_desc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[rep_lamp uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[rep_ballast uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]
                                                    , [[rep_real_watts uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]];
                                
                                csvFormat = [csvFormat stringByAppendingString:csvRow];
                            }
                            htmlFormat = [htmlFormat stringByAppendingString:@"</tbody></table></td></tr>"];
                        }
                        else {
                
                            NSString *csvRow = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"\n",  [[templateName uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[addrDesc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[dropboxLink uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [floor.fdesc stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[area.adesc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]];
                            csvFormat = [csvFormat stringByAppendingString:csvRow];
                        }
            
                        htmlFormat = [htmlFormat stringByAppendingString:@"</tbody></table></td></tr>"];
                    }
                }
                
                else {
                    NSString *csvRow = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\"\n",  [[templateName uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[addrDesc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[dropboxLink uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [floor.fdesc stringByReplacingOccurrencesOfString:@"\"" withString:@" "]];
                    csvFormat = [csvFormat stringByAppendingString:csvRow];
                }
                
                htmlFormat = [htmlFormat stringByAppendingString:@"</tbody></table></td></tr>"];
            }
        }
        else {
            NSString *csvRow = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\"\n",  [[templateName uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[addrDesc uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "], [[dropboxLink uppercaseString] stringByReplacingOccurrencesOfString:@"\"" withString:@" "]];
            csvFormat = [csvFormat stringByAppendingString:csvRow];
        }
        
        htmlFormat = [htmlFormat stringByAppendingString:@"</tbody></table></td><td colspan=\"1\" border=\"0\" width=\"20\" style=\"width: 20px\">&nbsp;</td><td colspan=\"1\" border=\"0\">&nbsp;</td></tr>"];
//        bodyString = [bodyString stringByAppendingString:@"</tbody></table></td><td colspan=\"1\" border=\"0\" width=\"20\" style=\"width: 20px\">&nbsp;</td><td colspan=\"1\" border=\"0\">&nbsp;</td></tr>"];
    }
    
    //Create csv file.
    NSString *csvFullPathName = [global.wattSwapDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.csv", global.surveyNamePath, global.surveyID]];
    
    NSError *error = nil;
    if([csvFormat writeToFile:csvFullPathName atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO)
    {
        return nil;
    }
    
    global.csvURI = csvFullPathName;
    htmlFormat = [htmlFormat stringByAppendingString:@"</tbody></table>"];
    bodyString = [bodyString stringByAppendingString:@"</tbody></table>"];
    
    // insert grubs for images
    if(emailCheckImageView.tag == 1) {
        NSData *imageData = [NSData dataWithContentsOfFile:global.survey.ofp_path];
        if(imageData != nil) {
            bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"<p>survey&nbsp;:&nbsp;%@", global.survey.sname]];
            bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"<br/><img src=\"data:image/jpg;base64,%@\" width=\"%d\" height=\"%d\"/></p>", [imageData base64EncodedString], (int)(SCREEN_WIDTH-40), (int)(SCREEN_WIDTH-40)]];
        }
        NSArray *aryFixtureInfos = [APIService getObjectsFromCoreData:@"FixtureInfo" Where:[NSString stringWithFormat:@"ofp_sid == %@", global.survey.ofp_sid.stringValue]];
        for(int i=0; i<[aryFixtureInfos count]; i++) {
            FixtureInfo *fixtureInfo = [aryFixtureInfos objectAtIndex:i];
            NSData *imageData = [NSData dataWithContentsOfFile:fixtureInfo.ofp_path];
            if(imageData != nil) {
                bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"<p>fixture :&nbsp;%@,&nbsp;%@,&nbsp;%@", fixtureInfo.fixturetype, fixtureInfo.lamptype, fixtureInfo.lamp]];
                bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"<br/><img src=\"data:image/jpg;base64,%@\" width=\"%d\" height=\"%d\"/></p>", [imageData base64EncodedString], (int)(SCREEN_WIDTH-40), (int)(SCREEN_WIDTH-40)]];
            }
        }
    }
    
    UIDevice *myDevice = [UIDevice currentDevice];
    
    NSString *deviceUDID = [global getNewUDID];
    NSString *deviceName = [global getDeviceName];
    NSString *deviceSystemName = myDevice.systemName;
    NSString *deviceOSVersion = myDevice.systemVersion;
    NSString *deviceModel = myDevice.model;
    NSString *macAddress = [global getMacAddress];
    
    if (macAddress == nil) {
        macAddress = @"";
    }
    
    NSString *deviceInfoTable = [NSString stringWithFormat:@"<br/><br/><br/><h2>Device Info:</h2><table><tbody><tr><td>Device:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td>Model:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td>OS:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td>Manufacturer:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td>Product:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td>IMEI:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td>MAC Address:&nbsp;&nbsp;</td><td>%@</td><td style=\"width:20px\">&nbsp;&nbsp;&nbsp;&nbsp;</td></tr></tbody></table>", deviceName, deviceModel, deviceOSVersion, @"", deviceSystemName, deviceUDID, macAddress];
    
    htmlFormat = [htmlFormat stringByAppendingString:deviceInfoTable];
    bodyString = [bodyString stringByAppendingString:deviceInfoTable];
    
    htmlFormat = [htmlFormat stringByAppendingString:@"</body></html>"];
    bodyString = [bodyString stringByAppendingString:@"</body></html>"];
    
    NSString *htmlFullPathName = [global.wattSwapDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.html", global.surveyNamePath, global.surveyID]];
    if(![htmlFormat writeToFile:htmlFullPathName atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        return nil;
    }
    
    global.htmlURI = htmlFullPathName;
    global.surveyEmail = bodyString;
    global.surveyHtml = htmlFormat;
    
    return htmlFormat;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  NewFixtureViewController.m
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "NewFixtureViewController.h"
#import "AddFixtureCheckTableViewCell.h"
#import "DetailedFixtureViewController.h"
#import "Constants.h"
#import "APIService.h"
#import "CoredataManager.h"
#import "AddFixtureCheckLastTableViewCell.h"
#import "AppDelegate.h"
#import "JPSVolumeButtonHandler.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <AudioToolbox/AudioServices.h>


#define GET_OPTION_VALUE(widget)    ([widget.text isEqualToString:@"Please select..."] ? @"None" : widget.text)
#define IS_NONE_OPTION(val) ([val isEqualToString:@"None"])
#define IS_UNSETTED(widget)    (([widget.text isEqualToString:@"Please select..."] == YES))

#define INIT_FIXTURE_TYPE_OPTIONS(sources, type, name, fixture, prop, ctrl, optionList) {\
    NSMutableArray *optionArray = [[NSMutableArray alloc] init]; \
    NSArray *options = [sources objectForKey:type]; \
    /*ctrl.textColor = UIColorFromRGBValue(0xcccccc); */\
    if(ctrl.numberOfLines > 1) \
        [ctrl setFont:[UIFont fontWithName:@"Century Gothic" size:14]]; \
    /*ctrl.text = @"Please select...";*/ \
    for(int i=0; i<[options count]; i++) { \
        NSDictionary *one = options[i]; \
        NSString *optionName = [one objectForKey:name]; \
        [optionArray addObject:optionName]; \
        /*if(i==0) ctrl.text = optionName; \
        if(fixture != nil && [optionName isEqualToString:fixture.prop]) { \
            if(ctrl.numberOfLines > 1) \ 
                [ctrl setFont:[UIFont fontWithName:@"Century Gothic" size:14]]; \
            ctrl.textColor = UIColorFromRGBValue(0x000000); \
            ctrl.text = optionName; \
        } \*/ \
    } \
    optionList = (NSArray*)optionArray; \
}

#define INIT_FIXTURE_TYPE_OTHER_OPTIONS(sources, type, name, optionList) {\
    NSMutableArray *optionArray = [[NSMutableArray alloc] init]; \
    NSArray *options = [sources objectForKey:type]; \
    for(int i=0; i<[options count]; i++) { \
        NSDictionary *one = options[i]; \
        NSString *optionName = [one objectForKey:name]; \
        [optionArray addObject:optionName]; \
    } \
    optionList = (NSArray*)optionArray; \
}


#define INITIALIZE_OPIONS(ctrl, option) { \
    if(option == nil && [option isEqualToString:@"None"]) { \
        if(ctrl.numberOfLines > 1) \
            [ctrl setFont:[UIFont fontWithName:@"Century Gothic" size:20]]; \
        ctrl.textColor = UIColorFromRGBValue(0xcccccc); \
        ctrl.text = @"Please select..."; \
    } \
    else { \
        if(ctrl.numberOfLines > 1) \
            [ctrl setFont:[UIFont fontWithName:@"Century Gothic" size:14]]; \
        ctrl.textColor = UIColorFromRGBValue(0x000000); \
        ctrl.text = option; \
    } \
}

#define INITIALIZE_DEFAULT_OPTION(ctrl) { \
        if(ctrl.numberOfLines > 1) \
            [ctrl setFont:[UIFont fontWithName:@"Century Gothic" size:20]]; \
        ctrl.textColor = UIColorFromRGBValue(0xcccccc); \
        ctrl.text = @"Please select..."; \
}

@interface NewFixtureViewController ()
{
    NSArray *m_aryLampTypeDescriptions;
    NSArray *m_aryLampCodeDescriptions;
}

@property (strong, atomic) ALAssetsLibrary *library;
@property (strong, nonatomic) JPSVolumeButtonHandler *volumeButtonHandler;

@end

@implementation NewFixtureViewController

@synthesize scrollView, m_lblFloorAreaName, m_lblSurveyName, fixtureImageBtn, m_txtFixtureCnt, m_btnFixtureCntMinus, m_btnFixtureCntPlus, m_lblFixtureSize, m_lblFixtureType, m_lblLense, m_lblFixtureControlled, m_lblFixtureMounting, m_lblFixtureHeight, m_lblLampType, m_lblLampCode, m_lblLamp;

@synthesize m_lblFixtureBallastFactor, m_lblFixtureBallastType, m_txtHoursPerWeek, m_txtLampCount, m_textViewFixtureNotes, m_lblFixtureOption, m_txtLampWatts, m_lblFixtureStyle, m_lblFixtureWatts, m_txtHoursPerDay, m_txtDaysPerWeek, m_lblHoursPerYear, m_lblHoursPerWeek, m_lblReplacementLampDesc, m_selectedRetrofit;

@synthesize m_btnAddFixtureSize, m_btnAddFixtureType, m_btnAddLense, m_btnAddFixtureControlled, m_btnAddFixtureMounting, m_btnAddFixtureHeight, m_btnAddLampType, m_btnAddLampCode, m_btnAddLamp, m_btnAddBallastType, m_btnAddBallastFactor, m_btnAddFixtureStyle, m_btnAddFixtureOption, m_btnAddReplacementLamp;

@synthesize global, fixtureTypeStr, fixtureBallastFactorList, fixtureBallastTypeList, fixtureHeightList, fixtureMountingList, fixtureControlledList, fixtureOptionList, fixtureStyleList, fixtureTypeList, fixtureSizeList,lenseList, lampTypeList, lampCodeList, lampList, lampWatts, realLampWattageList;

@synthesize selectedIndex, selectedText, checkList, replacement_id;

@synthesize deleteAlert;

@synthesize fixtureImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap2Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture2:)];
    tap2Gesture.numberOfTapsRequired = 2;
    [m_btnAddReplacementLamp addGestureRecognizer:tap2Gesture];
    UITapGestureRecognizer *tap1Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture1:)];
    tap1Gesture.numberOfTapsRequired = 1;
    [m_btnAddReplacementLamp addGestureRecognizer:tap1Gesture];
    [tap1Gesture requireGestureRecognizerToFail:tap2Gesture];

    self.library = [[ALAssetsLibrary alloc] init];

    global = [Global sharedManager];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1460);

    NSDictionary *dicFixtureOptions = global.fixtureOptions;
    if(dicFixtureOptions != nil) {
        
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"fixture_sizes", @"fixture_size_name", global.fixture, fixturesize, m_lblFixtureSize, fixtureSizeList)
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"fixture_types", @"fixture_type_name", global.fixture, fixturetype, m_lblFixtureType, fixtureTypeList)
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"lenses", @"lense_name", global.fixture, lense, m_lblLense, lenseList)
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"fixture_controlled_options", @"fixture_controlled_name", global.fixture, control, m_lblFixtureControlled, fixtureControlledList)
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"fixture_mountings", @"fixture_mounting_name", global.fixture, mounting, m_lblFixtureMounting, fixtureMountingList)
        
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"lamp_types", @"lamp_type_name", global.fixture, lamptype, m_lblLampType, lampTypeList)
        INIT_FIXTURE_TYPE_OTHER_OPTIONS(global.fixtureOptions, @"lamp_types", @"lamp_type_desc", m_aryLampTypeDescriptions)
        
//        {
//            NSMutableArray *optionArray = [[NSMutableArray alloc] init];
//            NSArray *options = [global.fixtureOptions objectForKey:@"fixture_lamps"];
//            for(int i=0; i<[options count]; i++) {
//                NSDictionary *one = options[i];
//                NSString *optionName = [one objectForKey:@"lamp_name"];
//                NSString *realWatts = [one objectForKey:@"lamp_real_wattage"];
//                if(realWatts != nil && [realWatts isEqualToString:@""] == NO) {
//                    optionName = [optionName stringByAppendingString:@","];
//                    optionName = [optionName stringByAppendingString:realWatts];
//                }
//                [optionArray addObject:optionName];
//                if(i==0) m_lblLamp.text = optionName;
//                if(global.fixture != nil && [optionName isEqualToString:global.fixture.lamp])
//                    m_lblLamp.text = optionName;
//            }
//            lampList = (NSArray*)optionArray;
//        };
        
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"ballast_types", @"fixture_blast_type_name", global.fixture, ballasttype, m_lblFixtureBallastType, fixtureBallastTypeList)
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"ballast_factors", @"fixture_factor_name", global.fixture, ballastfactor, m_lblFixtureBallastFactor, fixtureBallastFactorList)
        INIT_FIXTURE_TYPE_OPTIONS(global.fixtureOptions, @"fixture_options", @"fixture_option_name", global.fixture, option, m_lblFixtureOption, fixtureOptionList)
        
//        realLampWattageList = [[NSMutableArray alloc] initWithArray:[dicFixtureOptions objectForKey:@"fixture_mountings"]];
//        lampWatts = [[NSMutableArray alloc] initWithArray:[dicFixtureOptions objectForKey:@"fixture_mountings"]];
//        lampCodeList = [[NSMutableArray alloc] initWithArray:[dicFixtureOptions objectForKey:@"fixture_mountings"]];
//        fixtureStyleList = [[NSMutableArray alloc] initWithArray:[dicFixtureOptions objectForKey:@"fixture_mountings"]];
    }
    
    fixtureHeightList = @[@"Normal", @"15+", @"20+", @"30+"];
    m_lblFixtureHeight.text = [fixtureHeightList objectAtIndex:0];

    m_lblSurveyName.text = global.surveyName;
    m_lblFloorAreaName.text = [NSString stringWithFormat:@"%@ / %@", global.floor.fdesc, global.area.adesc];
    
    m_txtFixtureCnt.delegate = self;
    
    m_textViewFixtureNotes.layer.borderWidth = 1.0f;
    m_textViewFixtureNotes.layer.borderColor = [[UIColor colorWithHexString:BLUE_TOPBAR_COLOR] CGColor];
    
    m_txtHoursPerDay.layer.borderWidth = 1.0f;
    m_txtHoursPerDay.layer.borderColor = [[UIColor colorWithHexString:BLUE_TOPBAR_COLOR] CGColor];
    
    m_txtDaysPerWeek.layer.borderWidth = 1.0f;
    m_txtDaysPerWeek.layer.borderColor = [[UIColor colorWithHexString:BLUE_TOPBAR_COLOR] CGColor];
    
    m_txtHoursPerWeek.layer.borderWidth = 1.0f;
    m_txtHoursPerWeek.layer.borderColor = [[UIColor colorWithHexString:BLUE_TOPBAR_COLOR] CGColor];
    
    m_txtLampCount.layer.borderWidth = 1.0f;
    m_txtLampCount.layer.borderColor = [[UIColor colorWithHexString:BLUE_TOPBAR_COLOR] CGColor];
    
    m_txtLampWatts.layer.borderWidth = 1.0f;
    m_txtLampWatts.layer.borderColor = [[UIColor colorWithHexString:BLUE_TOPBAR_COLOR] CGColor];
    
    checkList = [[NSMutableArray alloc] init];
    
    if (global.isUpdate) {
        
        if(global.fixture.replacement_id.intValue != 0) {
            NSArray *aryRetrofits = [APIService getObjectsFromCoreData:@"RetrofitInfo" Where:[NSString stringWithFormat:@"retrofit_id == %d", global.fixture.replacement_id.intValue]];
            if([aryRetrofits count] > 0) {
                m_selectedRetrofit = [aryRetrofits objectAtIndex:0];
                INITIALIZE_OPIONS(m_lblReplacementLampDesc, m_selectedRetrofit.retrofit_description)
            }
        }
        else {
            m_selectedRetrofit = nil;
            INITIALIZE_DEFAULT_OPTION(m_lblReplacementLampDesc);
        }
        
        m_txtFixtureCnt.text = global.fixture.fixturecnt;
        INITIALIZE_OPIONS(m_lblFixtureSize, global.fixture.fixturesize);
        INITIALIZE_OPIONS(m_lblFixtureType, global.fixture.fixturetype);
        INITIALIZE_OPIONS(m_lblLense, global.fixture.lense);
        INITIALIZE_OPIONS(m_lblFixtureControlled, global.fixture.control);
        INITIALIZE_OPIONS(m_lblFixtureMounting, global.fixture.mounting);
        INITIALIZE_OPIONS(m_lblFixtureHeight, global.fixture.height);
        INITIALIZE_OPIONS(m_lblLampType, global.fixture.lamptype);
        INITIALIZE_OPIONS(m_lblLampCode, global.fixture.lampcode);
        INITIALIZE_OPIONS(m_lblLamp, global.fixture.lamp);

        m_txtLampCount.text = global.fixture.bulbsperfixture;
        m_txtLampWatts.text = global.fixture.wattsperbulb;
        
        INITIALIZE_OPIONS(m_lblFixtureBallastType, global.fixture.ballasttype);
        INITIALIZE_OPIONS(m_lblFixtureBallastFactor, global.fixture.ballastfactor);
        INITIALIZE_OPIONS(m_lblFixtureStyle, global.fixture.style);
        INITIALIZE_OPIONS(m_lblFixtureOption, global.fixture.option);
        
        if(!(global.fixture.hoursperday.length == 0 || global.fixture.hoursperday.intValue == 0 ||
             global.fixture.daysperweek.length == 0 || global.fixture.daysperweek.intValue == 0)) {
            m_txtHoursPerDay.text = global.fixture.hoursperday;
            m_txtDaysPerWeek.text = global.fixture.daysperweek;
            m_lblHoursPerWeek.text = global.fixture.hoursperweek;
        }

        m_txtHoursPerWeek.text = global.fixture.hoursperweek;
        m_lblHoursPerYear.text = global.fixture.hoursinyear;
        m_textViewFixtureNotes.text = global.fixture.note;
        
        m_lblFixtureWatts.text = global.fixture.realwatts;
        self.replacement_id = global.fixture.replacement_id.intValue;
        
        NSString *imgPath = global.fixture.ofp_path;
        if(imgPath != nil && imgPath.length > 0)
        {
            fixtureImage = [UIImage imageWithContentsOfFile:imgPath];
            [self.fixtureImageView setImage:fixtureImage];
        }
        else
        {
            imgPath = global.fixture.path;
            if(imgPath != nil && imgPath.length > 0)
            {
                __weak NewFixtureViewController *weakSelf = self;
                NSURL *imageURL = [NSURL URLWithString:imgPath];
                [self.fixtureImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                                                     placeholderImage:nil
                                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite
                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                  fixtureImage = image;
                                                                  weakSelf.fixtureImageView.image = image;
                                                                  
                                                                  weakSelf.global.fixture.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"fixture_%@.png", weakSelf.global.fixture.ofp_fixtureid] FromImage:image];
                                                                  
                                                                  NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                                                                  NSError *error;
                                                                  [coreDataContext save:&error];
                                                              }
                                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                  NSLog(@"%@", error.description);
                                                              }];
            }
        }
        
        [self initFixtureListsWithLampType:global.fixture.lamptype Fixture:(global.isUpdate ? global.fixture : nil)];
        [self selectLamp:global.fixture.lamp];
    }
    else
    {
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureSize);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureType);
        INITIALIZE_DEFAULT_OPTION(m_lblLense);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureControlled);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureMounting);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureHeight);
        INITIALIZE_DEFAULT_OPTION(m_lblLampType);
        INITIALIZE_DEFAULT_OPTION(m_lblLampCode);
        INITIALIZE_DEFAULT_OPTION(m_lblLamp);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureBallastType);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureBallastFactor);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureStyle);
        INITIALIZE_DEFAULT_OPTION(m_lblFixtureOption);
        INITIALIZE_DEFAULT_OPTION(m_lblReplacementLampDesc);
    }
    
    if(global.bUseVolume) {
        self.volumeButtonHandler = [JPSVolumeButtonHandler volumeButtonHandlerWithUpBlock:^{
            // Volume Up Button Pressed
            [self fixtureCntPlusMinus:m_btnFixtureCntPlus];
        } downBlock:^{
            // Volume Down Button Pressed
            [self fixtureCntPlusMinus:m_btnFixtureCntMinus];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapGesture2:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        m_selectedRetrofit = nil;
        replacement_id = 0;
        INITIALIZE_DEFAULT_OPTION(m_lblReplacementLampDesc);
    }
}
- (void)handleTapGesture1:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        [self goDetailedFixture:nil];
    }
}

- (void)initFixtureListsWithLampType:(NSString*)ftype Fixture:(FixtureInfo*)fixture {
    
    NSDictionary *lampTypeOptions = [global getLampTypeOptionsByTypeName:ftype];
    if(lampTypeOptions != nil) {
        INIT_FIXTURE_TYPE_OPTIONS(lampTypeOptions, @"codes", @"lamp_code_name", global.fixture, lampcode, m_lblLampCode, lampCodeList)
        INIT_FIXTURE_TYPE_OTHER_OPTIONS(lampTypeOptions, @"codes", @"lamp_code_desc", m_aryLampCodeDescriptions)
        
        INIT_FIXTURE_TYPE_OPTIONS(lampTypeOptions, @"style", @"fixture_style_name", global.fixture, style, m_lblFixtureStyle, fixtureStyleList)
        
        {
            NSMutableArray *optionArray = [[NSMutableArray alloc] init];
            NSArray *options = [lampTypeOptions objectForKey:@"lamps"];
            for(int i=0; i<[options count]; i++) {
                NSDictionary *one = options[i];
                NSString *optionName = [one objectForKey:@"lamp_name"];
                NSString *realWatts = [one objectForKey:@"lamp_real_wattage"];
                if(realWatts != nil && [realWatts isEqualToString:@""] == NO) {
                    optionName = [optionName stringByAppendingString:@","];
                    optionName = [optionName stringByAppendingString:realWatts];
                }
                [optionArray addObject:optionName];
                if(i==0) m_lblLamp.text = optionName;
                if(global.fixture != nil && [optionName isEqualToString:global.fixture.lamp])
                    m_lblLamp.text = optionName;
            }
            lampList = (NSArray*)optionArray;
        };
    }
}

- (IBAction) goMenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) saveNewFixture:(id)sender
{
    /*if(IS_UNSETTED(m_lblFixtureSize)) {
        [self.view makeToast:@"Please select a value for fixture Size."];
        return;
    }
    
    if(IS_UNSETTED(m_lblFixtureType)) {
        [self.view makeToast:@"Please select a value for fixture type."];
        return;
    }

    if(IS_UNSETTED(m_lblFixtureControlled)) {
        [self.view makeToast:@"Please select a value for fixture controlled."];
        return;
    }

    if(IS_UNSETTED(m_lblFixtureMounting)) {
        [self.view makeToast:@"Please select a value for fixture mounting type."];
        return;
    }

    if(IS_UNSETTED(m_lblFixtureHeight)) {
        [self.view makeToast:@"Please select a value for fixture height."];
        return;
    }

    if(IS_UNSETTED(m_lblLampType)) {
        [self.view makeToast:@"Please select a value for lamp type."];
        return;
    }

    if(IS_UNSETTED(m_lblLampCode)) {
        [self.view makeToast:@"Please select a value for lamp code."];
        return;
    }

    if(IS_UNSETTED(m_lblLamp)) {
        [self.view makeToast:@"Please select a value for lamp."];
        return;
    }*/
    
    NSData *data = UIImageJPEGRepresentation(fixtureImage, 0.7f);
    NSString *base64Image = @"";
    if (data != nil) {
        base64Image = [data base64EncodedString];
    }
    
    if(global.isUpdate == NO) // add
    {
        // at first, save new data to local coredata
        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
        FixtureInfo *newFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
        
        newFixture.supervisor_id = global.supervisorID;
        newFixture.ofp_sid = global.area.ofp_sid;
        newFixture.sid = global.area.sid;
        
        newFixture.ofp_fid = global.area.ofp_fid;
        newFixture.fid = global.area.fid;
        
        newFixture.ofp_aid = global.area.ofp_aid;
        newFixture.aid = global.area.aid;
        
        newFixture.fixtureid = @0;
        newFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
        
        newFixture.fixturecnt = m_txtFixtureCnt.text;
        newFixture.fixturesize = GET_OPTION_VALUE(m_lblFixtureSize);
        newFixture.fixturetype = GET_OPTION_VALUE(m_lblFixtureType);
        newFixture.lense = GET_OPTION_VALUE(m_lblLense);
        newFixture.lamptype = GET_OPTION_VALUE(m_lblLampType);
        newFixture.lamp = GET_OPTION_VALUE(m_lblLamp);
        newFixture.realwatts = m_lblFixtureWatts.text;
        newFixture.lampcode = @"";
        newFixture.style = GET_OPTION_VALUE(m_lblFixtureStyle);
        newFixture.mounting = GET_OPTION_VALUE(m_lblFixtureMounting);
        newFixture.control = GET_OPTION_VALUE(m_lblFixtureControlled);
        newFixture.option = GET_OPTION_VALUE(m_lblFixtureOption);
        newFixture.height = GET_OPTION_VALUE(m_lblFixtureHeight);
        newFixture.note = m_textViewFixtureNotes.text;
        newFixture.hoursperday = m_txtHoursPerDay.text;
        newFixture.daysperweek = m_txtDaysPerWeek.text;
        
        NSString *strHoursPerWeek = m_lblHoursPerWeek.text;
        if(strHoursPerWeek.intValue == 0) {
            strHoursPerWeek = m_txtHoursPerWeek.text;
            if(strHoursPerWeek.length == 0)
                strHoursPerWeek = @"0";
        }
        newFixture.hoursperweek = strHoursPerWeek;
        newFixture.hoursinyear = [NSString stringWithFormat:@"%d", [strHoursPerWeek intValue] * 52];
        
        newFixture.bulbsperfixture = m_txtLampCount.text;
        newFixture.wattsperbulb = m_txtLampWatts.text;
        newFixture.ballasttype = GET_OPTION_VALUE(m_lblFixtureBallastType);
        newFixture.ballastfactor = GET_OPTION_VALUE(m_lblFixtureBallastFactor);
        newFixture.replacement_id = [NSNumber numberWithInt:self.replacement_id];
        newFixture.stime = SERVER_TIME([NSDate date]);
        
        if(fixtureImage != nil) {
            newFixture.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"fixture_%@.png", newFixture.ofp_fixtureid] FromImage:self.fixtureImageView.image];
            if(self.fixtureImageView.image != nil) {
                [self.library saveImage:self.fixtureImageView.image toAlbum:global.survey.sname withCompletionBlock:^(NSError *error) {
                    if (error!=nil) {
                        NSLog(@"Error in saving image like as : %@", [error description]);
                    }
                }];
            }
        }
        
        NSError *error;
        if(NO == [coreDataContext save:&error]) {
            [self.view makeToast:@"Failed in adding new fixture. App won't work rightly."];
            return;
        }
        
        // save new data to global array
        global.fixtureID = newFixture.ofp_fixtureid;
        global.fixture = newFixture;
        [global.fixturesArray addObject:newFixture];

        if(global.area.aid.intValue != 0) {
//            NSDictionary *params = @{@"supervisor_id":global.supervisorID, @"survey_id":global.area.sid, @"floor_id":global.area.fid, @"area_id":global.area.aid, @"count":m_txtFixtureCnt.text, @"fixture_type":GET_OPTION_VALUE(m_lblFixtureType), @"lamp_code":GET_OPTION_VALUE(m_lblLampCode), @"style":GET_OPTION_VALUE(m_lblFixtureStyle), @"mounting":GET_OPTION_VALUE(m_lblFixtureMounting), @"controlled":GET_OPTION_VALUE(m_lblFixtureControlled), @"option":GET_OPTION_VALUE(m_lblFixtureOption), @"height":GET_OPTION_VALUE(m_lblFixtureHeight), @"hrs_per_day":m_txtHoursPerDay.text, @"days_per_week":m_txtDaysPerWeek.text, @"notes":m_textViewFixtureNotes.text, @"ballast":GET_OPTION_VALUE(m_lblFixtureBallastType), @"factor":GET_OPTION_VALUE(m_lblFixtureBallastFactor), @"bulbs_per_fixture":m_txtLampCount.text, @"watts_per_bulb":m_txtLampWatts.text, @"fixture_images_b64":base64Image, @"replacement_id":newFixture.replacement_id, @"fixture_size":newFixture.fixturesize, @"lense":newFixture.lense, @"lamp_type":newFixture.lamptype, @"lamp":newFixture.lamp, @"lamp_real_wattage":newFixture.realwatts};
            
            NSDictionary *params = @{@"supervisor_id":global.supervisorID, @"survey_id":global.area.sid, @"floor_id":global.area.fid, @"area_id":global.area.aid, @"count":m_txtFixtureCnt.text, @"fixture_type":GET_OPTION_VALUE(m_lblFixtureType), @"lamp_code":@"", @"style":GET_OPTION_VALUE(m_lblFixtureStyle), @"mounting":GET_OPTION_VALUE(m_lblFixtureMounting), @"controlled":GET_OPTION_VALUE(m_lblFixtureControlled), @"option":GET_OPTION_VALUE(m_lblFixtureOption), @"height":GET_OPTION_VALUE(m_lblFixtureHeight), @"hrs_per_day":m_txtHoursPerDay.text, @"days_per_week":m_txtDaysPerWeek.text, @"notes":m_textViewFixtureNotes.text, @"ballast":GET_OPTION_VALUE(m_lblFixtureBallastType), @"factor":GET_OPTION_VALUE(m_lblFixtureBallastFactor), @"bulbs_per_fixture":m_txtLampCount.text, @"watts_per_bulb":m_txtLampWatts.text, @"fixture_images_b64":base64Image, @"replacement_id":newFixture.replacement_id, @"fixture_size":newFixture.fixturesize, @"lense":newFixture.lense, @"lamp_type":newFixture.lamptype, @"lamp":newFixture.lamp, @"lamp_real_wattage":newFixture.realwatts};
            
            [[APIService sharedManager] addFixture2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                if (error == nil) {
                    NSString *statusCode = [result objectForKey:@"status"];
                    NSDictionary* data = [[result objectForKey:@"data"] firstObject];
                    if ([statusCode isEqualToString:@"success"]) {
                        newFixture.fixtureid = NFS([data objectForKey:@"fixture_id"]);
                        newFixture.path = ISNull([data objectForKey:@"fixture_image"]) ? @"" : [data objectForKey:@"fixture_image"];
                        newFixture.stime = [global getDateFromString:[data objectForKey:@"create_ts"] Format:@"yyyy-MM-dd HH:mm:ss"];
                        [coreDataContext save:&error];
                    }
                }
            }];
        }
        [self.m_surveyPropTabPageVC goFixtureList];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        global.fixture.sid = global.area.sid;
        global.fixture.fid = global.area.fid;
        global.fixture.aid = global.area.aid;
        global.fixture.fixturesize = GET_OPTION_VALUE(m_lblFixtureSize);
        global.fixture.fixturetype = GET_OPTION_VALUE(m_lblFixtureType);
        global.fixture.fixturecnt = m_txtFixtureCnt.text;
        global.fixture.lense = GET_OPTION_VALUE(m_lblLense);
        global.fixture.lamptype = GET_OPTION_VALUE(m_lblLampType);
        global.fixture.lamp = GET_OPTION_VALUE(m_lblLamp);
        //global.fixture.lampcode = GET_OPTION_VALUE(m_lblLampCode);
        global.fixture.lampcode = @"";
        global.fixture.style = GET_OPTION_VALUE(m_lblFixtureStyle);
        global.fixture.mounting = GET_OPTION_VALUE(m_lblFixtureMounting);
        global.fixture.option = GET_OPTION_VALUE(m_lblFixtureOption);
        global.fixture.control = GET_OPTION_VALUE(m_lblFixtureControlled);
        global.fixture.height = GET_OPTION_VALUE(m_lblFixtureHeight);
        global.fixture.note = m_textViewFixtureNotes.text;
        global.fixture.hoursperday = m_txtHoursPerDay.text;
        global.fixture.daysperweek = m_txtDaysPerWeek.text;
        
        NSString *strHoursPerWeek = m_lblHoursPerWeek.text;
        if(strHoursPerWeek.intValue == 0) {
            strHoursPerWeek = m_txtHoursPerWeek.text;
            if(strHoursPerWeek.length == 0)
                strHoursPerWeek = @"0";
        }
        global.fixture.hoursperweek = strHoursPerWeek;
        global.fixture.hoursinyear = [NSString stringWithFormat:@"%d", (strHoursPerWeek.intValue * 52)];
        
        global.fixture.bulbsperfixture = m_txtLampCount.text;
        global.fixture.wattsperbulb = m_txtLampWatts.text;
        global.fixture.realwatts = m_lblFixtureWatts.text;
        global.fixture.ballasttype = GET_OPTION_VALUE(m_lblFixtureBallastType);
        global.fixture.ballastfactor = GET_OPTION_VALUE(m_lblFixtureBallastFactor);
        global.fixture.replacement_id = [NSNumber numberWithInt:self.replacement_id];
        global.fixture.stime = SERVER_TIME([NSDate date]);
        
        if(fixtureImage != nil) {
            global.fixture.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"fixture_%@.png", global.fixture.ofp_fixtureid] FromImage:self.fixtureImageView.image];;
            if(self.fixtureImageView.image != nil) {
                [self.library saveImage:self.fixtureImageView.image toAlbum:global.fixture.fixturetype withCompletionBlock:^(NSError *error) {
                    if (error!=nil) {
                        NSLog(@"Error in saving image like as : %@", [error description]);
                    }
                }];
            }
        }
        
        NSError *error;
        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
        
        if(![coreDataContext save:&error]){
            [self.view makeToast:error.description];
            return;
        }

        if(global.fixture.aid.intValue != 0)
        {
            if(global.fixture.fixtureid.intValue != 0)
            {
                NSDictionary *params = @{@"supervisor_id":global.supervisorID, @"survey_id":global.area.sid, @"floor_id":global.area.fid, @"area_id":global.area.aid, @"fixture_id":global.fixture.fixtureid, @"count":m_txtFixtureCnt.text, @"fixture_type":GET_OPTION_VALUE(m_lblFixtureType), @"lamp_code":@"", @"style":GET_OPTION_VALUE(m_lblFixtureStyle), @"mounting":GET_OPTION_VALUE(m_lblFixtureMounting), @"controlled":GET_OPTION_VALUE(m_lblFixtureControlled), @"option":GET_OPTION_VALUE(m_lblFixtureOption), @"height":GET_OPTION_VALUE(m_lblFixtureHeight), @"hrs_per_day":m_txtHoursPerDay.text, @"days_per_week":m_txtDaysPerWeek.text, @"notes":m_textViewFixtureNotes.text, @"ballast":GET_OPTION_VALUE(m_lblFixtureBallastType), @"factor":GET_OPTION_VALUE(m_lblFixtureBallastFactor), @"bulbs_per_fixture":m_txtLampCount.text, @"watts_per_bulb":m_txtLampWatts.text, @"fixture_images_b64":base64Image, @"replacement_id":global.fixture.replacement_id, @"fixture_size":GET_OPTION_VALUE(m_lblFixtureSize), @"lense":GET_OPTION_VALUE(m_lblLense), @"lamp_type":GET_OPTION_VALUE(m_lblLampType), @"lamp":GET_OPTION_VALUE(m_lblLamp), @"lamp_real_wattage":m_lblFixtureWatts.text};
                
                [[APIService sharedManager] saveFixture2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    if(error == nil)
                    {
                        NSString *statusCode = [result objectForKey:@"status"];
                        NSDictionary* data = [[result objectForKey:@"data"] firstObject];
                        if ([statusCode isEqualToString:@"success"])
                        {
                            NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                            global.fixture.path = (ISNull([data objectForKey:@"fixture_image"]) ? @"" : [data objectForKey:@"fixture_image"]);
                            global.fixture.stime = [global getDateFromString:[data objectForKey:@"create_ts"] Format:@"yyyy-MM-dd HH:mm:ss"];
                            [coreDataContext save:&error];
                        }
                        else
                            [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Fixture" ObjId:global.fixture.ofp_fixtureid];
                   }
                    else
                        [[APIService sharedManager] setObjectAsUnsync:@"Unsaved_Fixture" ObjId:global.fixture.ofp_fixtureid];
                    
                    [SVProgressHUD dismiss];
                }];
            }
            else
            {
                NSDictionary *params = @{@"supervisor_id":global.supervisorID, @"survey_id":global.area.sid, @"floor_id":global.area.fid, @"area_id":global.area.aid, @"count":m_txtFixtureCnt.text, @"fixture_type":GET_OPTION_VALUE(m_lblFixtureType), @"lamp_code":@"", @"style":GET_OPTION_VALUE(m_lblFixtureStyle), @"mounting":GET_OPTION_VALUE(m_lblFixtureMounting), @"controlled":GET_OPTION_VALUE(m_lblFixtureControlled), @"option":GET_OPTION_VALUE(m_lblFixtureOption), @"height":GET_OPTION_VALUE(m_lblFixtureHeight), @"hrs_per_day":m_txtHoursPerDay.text, @"days_per_week":m_txtDaysPerWeek.text, @"notes":m_textViewFixtureNotes.text, @"ballast":GET_OPTION_VALUE(m_lblFixtureBallastType), @"factor":GET_OPTION_VALUE(m_lblFixtureBallastFactor), @"bulbs_per_fixture":m_txtLampCount.text, @"watts_per_bulb":m_txtLampWatts.text, @"fixture_images_b64":base64Image, @"replacement_id":global.fixture.replacement_id, @"fixture_size":GET_OPTION_VALUE(m_lblFixtureSize), @"lense":GET_OPTION_VALUE(m_lblLense), @"lamp_type":GET_OPTION_VALUE(m_lblLampType), @"lamp":GET_OPTION_VALUE(m_lblLamp), @"lamp_real_wattage":m_lblFixtureWatts.text};
                
                [[APIService sharedManager] addFixture2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                    NSString *statusCode = [result objectForKey:@"status"];
                    NSDictionary* data = [[result objectForKey:@"data"] firstObject];
                    if ([statusCode isEqualToString:@"success"])
                    {
                        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                        global.fixture.fixtureid = NFS([data objectForKey:@"fixture_id"]);
                        global.fixture.path = (ISNull([data objectForKey:@"fixture_image"]) ? @"" : [data objectForKey:@"fixture_image"]);
                        global.fixture.stime = [global getDateFromString:[data objectForKey:@"create_ts"] Format:@"yyyy-MM-dd HH:mm:ss"];
                        [coreDataContext save:&error];
                    }

                    [SVProgressHUD dismiss];
                }];
            }
            
            [self.m_surveyPropTabPageVC goFixtureList];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction) goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) loadFixtureImage:(id)sender {
    if(fixtureImage == nil) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take from camera" otherButtonTitles:@"Select from gallery", nil];
        actionSheet.tag = 0; // without option 'Delete image'
        
        [actionSheet showInView:self.view];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take from camera" otherButtonTitles:@"Select from gallery", @"Delete image", nil];
        actionSheet.tag = 1;
        
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
        if(actionSheet.tag == 1) {
            deleteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you'd like to delete this fixture image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            deleteAlert.tag = 30;
            [deleteAlert show];
        }
    }
    else if(buttonIndex == 3)
    {
        NSLog(@"Update Button Clicked");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    fixtureImage = [Global croppedImage:img];
    self.fixtureImageView.image = fixtureImage;
}

- (IBAction) fixtureCntPlusMinus:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    if(global.bPlaySound)
        [appDelegate playSystemSound:([self.m_btnFixtureCntPlus isEqual:sender])];
    
    if(global.bUseVibration)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if ([m_btnFixtureCntMinus isEqual:sender]) {
        int cnt = [m_txtFixtureCnt.text intValue];
        cnt--;
        if (cnt < 1) {
            cnt = 0;
        }
        m_txtFixtureCnt.text = [NSString stringWithFormat:@"%d", cnt];
    }
    else {
        int cnt = [m_txtFixtureCnt.text intValue];
        cnt++;
        m_txtFixtureCnt.text = [NSString stringWithFormat:@"%d", cnt];
    }
}

- (int) selectOptionsOfObject:(NSArray*)optionList SelectedValues:(NSString*)values
{
    for(int i=0; i < [optionList count]; i++)
    {
        NSString *option = [optionList objectAtIndex:i];
        if([values isEqualToString:option])
            return i;
    }
    
    return -1;
}

- (void) selectCheckedOptionsOfObject:(NSArray*)optionList SelectedValues:(NSString*)values TableView:(UITableView*)tableView
{
    for(int s=0; s < [checkList count]; s++) {
        NSString *str = [checkList objectAtIndex:s];
        BOOL isFound = NO;
        for(int i=0; i < [optionList count]; i++)
        {
            NSString *option = [optionList objectAtIndex:i];
            if([str isEqualToString:option])
            {
                AddFixtureCheckTableViewCell *cell = (AddFixtureCheckTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                [cell setCheckStatus:YES];
                isFound = YES;
            }
        }
        if(isFound == NO)
        {
            AddFixtureCheckLastTableViewCell *cell = (AddFixtureCheckLastTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[optionList count] inSection:0]];
            cell.otherOption.text = str;
            [cell setCheckStatus:YES];
            isFound = YES;

        }
    }
}

- (void) updateWattagesFromUI {
    
    NSNumber *wattages = [NSNumber numberWithInt:[global getStandardWattagesOfFixtureWithType:m_lblFixtureType.text Code:m_lblLampCode.text]];
    if(wattages.intValue != 0) {
        [m_txtLampWatts setText:wattages.stringValue];
    }
}

- (IBAction) showAddView:(id)sender {
    [m_txtFixtureCnt resignFirstResponder];
    [m_txtHoursPerDay resignFirstResponder];
    [m_txtDaysPerWeek resignFirstResponder];
    [m_textViewFixtureNotes resignFirstResponder];
    [m_txtLampCount resignFirstResponder];
    [m_txtLampWatts resignFirstResponder];

    OptionTableFormView *optionTable = optionTable = [[[NSBundle mainBundle] loadNibNamed:@"OptionTableFormView" owner:nil options:nil] objectAtIndex:0];
    
    if([m_btnAddFixtureSize isEqual: sender]) {

        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeFixtureSizeListTable;
        optionTable.m_lblBudy = m_lblFixtureSize;
        [optionTable showOptionTable:self.view Title:@"Select Fixture Size" Options:fixtureSizeList SelectedOptions:@[m_lblFixtureSize.text]];
    }
    
    if ([m_btnAddFixtureType isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeFixtureTypeListTable;
        optionTable.m_lblBudy = m_lblFixtureType;
        [optionTable showOptionTable:self.view Title:@"Select Type" Options:fixtureTypeList SelectedOptions:@[m_lblFixtureType.text]];
    }
    
    if ([m_btnAddLense isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeLenseListTable;
        optionTable.m_lblBudy = m_lblLense;
        [optionTable showOptionTable:self.view Title:@"Select Lense" Options:lenseList SelectedOptions:@[m_lblLense.text]];
    }
    
    if ([m_btnAddFixtureControlled isEqual:sender]) {
        [optionTable setEnableMultipleSelection:YES];
        optionTable.tag = WATTSWAPTableTypeFixtureControlledListTable;
        optionTable.m_lblBudy = m_lblFixtureControlled;
        [optionTable showOptionTable:self.view Title:@"Select Control" Options:fixtureControlledList SelectedOptions:[m_lblFixtureControlled.text componentsSeparatedByString:@","]];
    }
    
    if ([m_btnAddFixtureMounting isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:YES];
        optionTable.tag = WATTSWAPTableTypeFixtureMountingListTable;
        optionTable.m_lblBudy = m_lblFixtureMounting;
        [optionTable showOptionTable:self.view Title:@"Select Mount" Options:fixtureMountingList SelectedOptions:[m_lblFixtureMounting.text componentsSeparatedByString:@","]];
    }
    
    if ([m_btnAddFixtureHeight isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:YES];
        optionTable.tag = WATTSWAPTableTypeFixtureHeightListTable;
        optionTable.m_lblBudy = m_lblFixtureHeight;
        [optionTable showOptionTable:self.view Title:@"Select Height" Options:fixtureHeightList SelectedOptions:[m_lblFixtureHeight.text componentsSeparatedByString:@","]];
    }
    
    if ([m_btnAddLampType isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeLampTypeListTable;
        optionTable.m_lblBudy = m_lblLampType;
        [optionTable showOptionTable:self.view Title:@"Select Lamp Type" Options:lampTypeList Others:m_aryLampTypeDescriptions SelectedOptions:@[m_lblLampType.text]];
    }
    
    if ([m_btnAddLampCode isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeLampCodeListTable;
        optionTable.m_lblBudy = m_lblLampCode;
        [optionTable showOptionTable:self.view Title:@"Select Lamp Code" Options:lampCodeList Others:m_aryLampCodeDescriptions SelectedOptions:@[m_lblLampCode.text]];
    }
    
    if ([m_btnAddLamp isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeLampListTable;
        optionTable.m_lblBudy = m_lblLamp;
        [optionTable showOptionTable:self.view Title:@"Select Lamp" Options:lampList SelectedOptions:@[m_lblLamp.text]];
    }
    
    if ([m_btnAddBallastType isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:YES];
        optionTable.tag = WATTSWAPTableTypeFixtureBallastTypeTable;
        optionTable.m_lblBudy = m_lblFixtureBallastType;
        optionTable.m_bEnableEmptyItem = YES;
        [optionTable showOptionTable:self.view Title:@"Select Ballast Type" Options:fixtureBallastTypeList SelectedOptions:[m_lblFixtureBallastType.text componentsSeparatedByString:@","]];
    }
    
    if ([m_btnAddBallastFactor isEqual:sender]) {
        [optionTable setEnableMultipleSelection:YES];
        optionTable.tag = WATTSWAPTableTypeFixtureBallastFactorListTable;
        optionTable.m_lblBudy = m_lblFixtureBallastFactor;
        optionTable.m_bEnableEmptyItem = YES;
        [optionTable showOptionTable:self.view Title:@"Select Ballast Factor" Options:fixtureBallastFactorList SelectedOptions:[m_lblFixtureBallastFactor.text componentsSeparatedByString:@","]];
    }
    
    if ([m_btnAddFixtureStyle isEqual:sender]) {
        
        [optionTable setEnableMultipleSelection:NO];
        optionTable.tag = WATTSWAPTableTypeFixtureStyleListTable;
        optionTable.m_lblBudy = m_lblFixtureStyle;
        [optionTable showOptionTable:self.view Title:@"Select Style" Options:fixtureStyleList SelectedOptions:@[m_lblFixtureStyle.text]];
    }
    
    if ([m_btnAddFixtureOption isEqual:sender]) {

        [optionTable setEnableMultipleSelection:YES];
        optionTable.tag = WATTSWAPTableTypeFixtureOptionListTable;
        optionTable.m_lblBudy = m_lblFixtureOption;
        [optionTable showOptionTable:self.view Title:@"Select Option" Options:fixtureOptionList SelectedOptions:[m_lblFixtureOption.text componentsSeparatedByString:@","]];
    }
    
    if(optionTable != nil)
        optionTable.delegate = self;
}

- (IBAction) goDetailedFixture:(id)sender {
    
    if(global.survey.rateperwatt.floatValue == 0.0f) {
        [self.view makeToast:@"Please go to survey page and input kWh rate."];
        return;
    }
    
    if(m_txtFixtureCnt.text.intValue == 0) {
        [self.view makeToast:@"Please input count of bulbs."];
        return;
    }
    
    NSString *strHoursPerWeek = m_lblHoursPerWeek.text;
    if(strHoursPerWeek.intValue == 0) {
        strHoursPerWeek = m_txtHoursPerWeek.text;
        if(strHoursPerWeek.length == 0)
            strHoursPerWeek = @"0";
    }

    DetailedFixtureViewController *detailedFixtureCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailedFixtureCtrl"];
    
    //detailedFixtureCtrl.fixtureTypeStyleNameText = [NSString stringWithFormat:@"%@ | %@", m_lblFixtureType.text, m_lblLampCode.text];
    detailedFixtureCtrl.fixtureTypeStyleNameText = [NSString stringWithFormat:@"%@", m_lblFixtureType.text];
    detailedFixtureCtrl.fixtureCntText = m_txtFixtureCnt.text;
    detailedFixtureCtrl.hoursPerWeekText = strHoursPerWeek;
    detailedFixtureCtrl.fixtureWattsText = m_lblFixtureWatts.text;
    
    detailedFixtureCtrl.fixtureType = m_lblFixtureType.text;
    detailedFixtureCtrl.fixtureLamp = m_lblLamp.text;
    detailedFixtureCtrl.replacement_id = replacement_id;
    detailedFixtureCtrl.delegate = self;
    
    [self.navigationController pushViewController:detailedFixtureCtrl animated:YES];
}

- (IBAction) deleteFixture:(id)sender {
    if (global.isUpdate) {
        deleteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want remove all data of this fixture?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        deleteAlert.tag = 10;
        [deleteAlert show];
    }
    else {
        [self.view makeToast:@"Recorded not saved"];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if(alertView == deleteAlert) {
            if(alertView.tag == 10) {
                
                NSNumber *fixture_id = global.fixture.fixtureid;
                
                [global.fixturesArray removeObject:global.fixture];
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                [coreDataContext deleteObject:global.fixture];
                
                NSError *error1;
                if(NO == [coreDataContext save:&error1]) {
                    [self.view makeToast:error1.description];
                    return;
                }
                
                if(fixture_id.intValue != 0)
                {
                    NSDictionary *params = @{@"fixture_id":fixture_id};
                    [[APIService sharedManager] deleteFixtureFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
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
                [self.navigationController popViewControllerAnimated:YES];
                
            } else if(alertView.tag == 30) {
                
                fixtureImage = nil;
                UIImage * defaultImage = [UIImage imageNamed: @"icon_camera.png"];
                self.fixtureImageView.image = defaultImage;

            }
        }
    }
}

- (void)selectLamp:(NSString*)option {
    
    if(IS_NONE_OPTION(option)) {
        
        m_lblLamp.text = @"";
        m_txtLampWatts.text = @"";
        m_txtLampCount.text = @"";
        m_lblFixtureWatts.text = @"";
        [m_lblLamp setFont:[UIFont fontWithName:@"Century Gothic" size:20]]; \

        return;
    }
    
    if ([option isEqualToString:@"Other"]) {
        m_lblLamp.text = option;
    }
    else {
        NSArray *aryLamps = [global.fixtureOptions objectForKey:@"lamp_types"];
        
        NSDictionary *dicLamp = nil;
        for (NSDictionary *_lamps in aryLamps) {
            NSDictionary *__lamps = [_lamps objectForKey:@"lamps"];
            for (NSDictionary *_dicLamp in __lamps) {
                NSString *_option = [option substringWithRange: NSMakeRange(0, [option rangeOfString: @"W"].location+1)];
                
                if ([[_dicLamp objectForKey:@"lamp_name"] isEqualToString:_option]) {
                    dicLamp = _dicLamp;
                    int iLampCount = ((NSString*)[dicLamp objectForKey:@"lamp_lamps"]).intValue;
                    int iRealLampWattage = ((NSString*)[dicLamp objectForKey:@"lamp_real_wattage"]).intValue;
                    NSString *strWatts = [dicLamp objectForKey:@"lamp_watts"];
                    //            NSString *strLampDesc = [dicLamp objectForKey:@"lamp_desc"];
                    
                    m_lblLamp.text = option;
                    
                    //            if(m_lblLamp.numberOfLines > 1) {
                    //                if(strLampDesc.length > 0) {
                    //                    m_lblLamp.text = [NSString stringWithFormat:@"%@\r\n%@",option, strLampDesc];
                    //                }
                    //                [m_lblLamp setFont:[UIFont fontWithName:@"Century Gothic" size:14]];
                    //            }
                    
                    if(iLampCount > 0) {
                        [m_txtLampCount setText: [NSNumber numberWithInt:iLampCount].stringValue];
                        [m_txtLampWatts setText:strWatts];
                        [m_lblFixtureWatts setText:[NSNumber numberWithInt:iRealLampWattage].stringValue];
                    }
                    
                    break;
                }
            }
        }
    }
    
    
//    for(int i=0; i<[lampList count]; i++) {
//        NSString *strLamp = [lampList objectAtIndex:i];
//        if([strLamp isEqualToString:option]) {
//            NSDictionary *dicLampArrays = [[aryLamps objectAtIndex:i] objectForKey:@"lamps"];
//            NSDictionary *dicLamp = nil;
//            for (NSDictionary *_dicLamp in dicLampArrays ) {
//                if ([[_dicLamp objectForKey:@"lamp_name"] isEqualToString:option]) {
//                    dicLamp = _dicLamp;
//                }
//            }
//            
//            int iLampCount = ((NSString*)[dicLamp objectForKey:@"lamp_lamps"]).intValue;
//            int iRealLampWattage = ((NSString*)[dicLamp objectForKey:@"lamp_real_wattage"]).intValue;
//            NSString *strWatts = [dicLamp objectForKey:@"lamp_watts"];
////            NSString *strLampDesc = [dicLamp objectForKey:@"lamp_desc"];
//            
//            m_lblLamp.text = option;
//            
////            if(m_lblLamp.numberOfLines > 1) {
////                if(strLampDesc.length > 0) {
////                    m_lblLamp.text = [NSString stringWithFormat:@"%@\r\n%@",option, strLampDesc];
////                }
////                [m_lblLamp setFont:[UIFont fontWithName:@"Century Gothic" size:14]];
////            }
//            
//            if(iLampCount > 0) {
//                [m_txtLampCount setText: [NSNumber numberWithInt:iLampCount].stringValue];
//                [m_txtLampWatts setText:strWatts];
//                [m_lblFixtureWatts setText:[NSNumber numberWithInt:iRealLampWattage].stringValue];
//            }
//            
//            break;
//        }
//    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

# pragma mark - OptionTableViewDelegate
- (void)didSelectedOptions:(NSArray*)options OptionTableView:(UIView*)view {
    
}

- (void)didSelectedOption:(NSString*)option OptionTableView:(UIView*)view {
    if(view.tag == WATTSWAPTableTypeLampTypeListTable) {
        [self initFixtureListsWithLampType:option Fixture:global.fixture];
//        [self updateWattagesFromUI];
    }
    else if(view.tag == WATTSWAPTableTypeLampListTable) {
        [self selectLamp:option];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *predicated = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(predicated.length > 0 && predicated.intValue == 0) return NO;
    
    if(predicated.length == 0)
        predicated = @"0";
    
    if ([textField isEqual:m_txtLampCount]) {
        if (predicated.length > 0 && m_txtLampWatts.text.length > 0) {
            m_lblFixtureWatts.text = [NSString stringWithFormat:@"%d", [predicated intValue] * [m_txtLampWatts.text intValue]];
        }
    }
    
    if ([textField isEqual:m_txtLampWatts]) {
        if (m_txtLampCount.text.length > 0 && predicated.length > 0) {
            m_lblFixtureWatts.text = [NSString stringWithFormat:@"%d", [m_txtLampCount.text intValue] * [predicated intValue]];
        }
    }
    
    if ([textField isEqual:m_txtHoursPerDay]) {
        if(predicated.intValue > 24) return NO;
        if (predicated.length > 0 && m_txtDaysPerWeek.text.length > 0) {
            m_lblHoursPerWeek.text = [NSString stringWithFormat:@"%d", [predicated intValue] * [m_txtDaysPerWeek.text intValue]];
        }
    }
    if ([textField isEqual:m_txtDaysPerWeek]) {
        if(predicated.intValue > 7) return NO;
        if (m_txtHoursPerDay.text.length > 0 && predicated.length > 0) {
            m_lblHoursPerWeek.text = [NSString stringWithFormat:@"%d", [m_txtHoursPerDay.text intValue] * [predicated intValue]];
        }
    }
    if([textField isEqual:m_txtHoursPerWeek]) {
        if(predicated.intValue > 168) return NO;
        m_lblHoursPerYear.text = [NSString stringWithFormat:@"%d", [predicated intValue] * 52];
    }
    return YES;
}

#pragma mark - DetailFixtureViewControllerDelegate
-(void) didChangedReplacement:(int)replacementId {
    replacement_id = replacementId;
    if(replacementId == 0) {
        m_selectedRetrofit = nil;
        INITIALIZE_DEFAULT_OPTION(m_lblReplacementLampDesc);
    }
    else {
        NSArray *aryRetrofits = [APIService getObjectsFromCoreData:@"RetrofitInfo" Where:[NSString stringWithFormat:@"retrofit_id == %d", replacement_id]];
        if([aryRetrofits count] > 0) {
            m_selectedRetrofit = [aryRetrofits objectAtIndex:0];
            INITIALIZE_OPIONS(m_lblReplacementLampDesc, m_selectedRetrofit.retrofit_description)
        }
    }
}

@end

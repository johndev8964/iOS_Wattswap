//
//  Global.h
//  Wattswap
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SurveyInfo.h"
#import "FloorInfo.h"
#import "AreaInfo.h"
#import "FixtureInfo.h"
#import "OperationInfo.h"
#import "ConversionInfo.h"
#import "RetrofitInfo.h"
#import <MFSideMenu.h>

#define STR_ZERO  @"0"
#define ISNull(x) (x == nil || x == [NSNull null])
// iPhone Size
#define IS_IPAD_ (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define APP_CUSTOM_QUEUE dispatch_queue_create("com.ws.wattswap.converionImagesDownLodingQueue", NULL)
#define CONVERSION_CANDI_IMAGE_NAME(cid) [NSString stringWithFormat:@"conversion_candi_%@.jpeg", cid]

#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f green:((float)((rgbValue & 0xFF00) >> 8))/255.0f blue:((float)(rgbValue & 0xFF))/255.0f alpha:1.0]

#define NFS(X) ([NSNumber numberWithInt:((NSString*)X).intValue])
#define SERVER_TIME(ld) ([ld dateByAddingTimeInterval:((Global*)[Global sharedManager]).g_timeDiff2Server])
#define LOCAL_TIME(sd) [sd dateByAddingTimeInterval:(-1*((Global*)[Global sharedManager]).g_timeDiff2Server)]

#define UDS_KEY_USE_VOLUME_FCB      @"use_volume_fixture_counting_buttons"
#define UDS_KEY_USE_SOUND_FCB       @"use_sound_fixture_counting_buttons"
#define UDS_KEY_USE_VIBRATION_FCB   @"use_vibration_fixture_counting_buttons"

#define SURVEY_STATUS_ACTIVE        0
#define SURVEY_STATUS_INAVTIVE      1

@interface Global : NSObject

@property (nonatomic, retain) NSString *supervisorID;
@property (nonatomic, retain) NSNumber *surveyID;
@property (nonatomic, retain) NSNumber *floorID;
@property (nonatomic, retain) NSNumber *areaID;
@property (nonatomic, retain) NSNumber *fixtureID;

@property (nonatomic, retain) NSString *wattSwapDirectory;

@property (nonatomic, retain) NSString *surveyName;
@property (nonatomic, retain) NSString *surveyNamePath;
@property (nonatomic, retain) NSString *fixtureTypeName;
@property (nonatomic, retain) NSString *htmlURI;
@property (nonatomic, retain) NSString *csvURI;
@property (nonatomic, retain) NSString *imgName;

@property (nonatomic, retain) NSString *surveyEmail;
@property (nonatomic, retain) NSString *surveyHtml;

@property (nonatomic) Boolean isUpdate;
@property (nonatomic) Boolean toFloor;
@property (nonatomic, retain) SurveyInfo *survey;
@property (nonatomic, retain) FloorInfo  *floor;
@property (nonatomic, retain) AreaInfo   *area;
@property (nonatomic, retain) FixtureInfo *fixture;
@property (nonatomic, retain) NSMutableArray *floorsArray;
@property (nonatomic, retain) NSMutableArray *areasArray;
@property (nonatomic, retain) NSMutableArray *fixturesArray;

@property (nonatomic, retain) NSMutableArray *syncSurveys;
@property (nonatomic, retain) NSMutableArray *syncFloors;
@property (nonatomic, retain) NSMutableArray *syncAreas;
@property (nonatomic, retain) NSMutableArray *syncFixtures;

@property(retain, nonatomic) NSMutableDictionary *g_dicOthers;

@property (nonatomic, retain) NSDictionary *fixtureOptions;
@property (nonatomic, retain) NSArray *states;

// member variables for codedata primary key
@property (nonatomic, readwrite) UInt64    max_survey_id;
@property (nonatomic, readwrite) UInt64    max_floor_id;
@property (nonatomic, readwrite) UInt64    max_area_id;
@property (nonatomic, readwrite) UInt64    max_fixture_id;

@property (nonatomic, readwrite) BOOL     internetConnected;
@property (nonatomic, readwrite) BOOL     isUploading;
@property (nonatomic, readwrite) NSTimeInterval    g_timeDiff2Server;

@property (strong, nonatomic) MFSideMenuContainerViewController* g_sideMenu;

@property (nonatomic, readwrite) BOOL     bUseVolume;
@property (nonatomic, readwrite) BOOL     bPlaySound;
@property (nonatomic, readwrite) BOOL     bUseVibration;


+ (id)sharedManager;

- (NSDate *) getDateFromString:(NSString *)str Format:(NSString*)fmt;
- (NSString *) getStringFromDate:(NSDate *)date Format:(NSString*)fmt;
- (NSString *) getNewUDID;
- (NSString *) getDeviceName;
- (NSString *) getMacAddress;
- (NSDictionary*) getLampTypeOptionsByTypeName:(NSString*)type;
- (NSArray*) getFixtureTypes;

- (NSString*) getStateNameById:(NSString*)stateID;
- (int) getStateIndexByName:(NSString*)stateName;
- (NSString*) getStateIdByName:(NSString*)stateName;


- (NSNumber*) getMaxSurveyValue:(BOOL)inc;
- (NSNumber*) getMaxFloorValue:(BOOL)inc;
- (NSNumber*) getMaxAreaValue:(BOOL)inc;
- (NSNumber*) getMaxFixtureValue:(BOOL)inc;

- (int) numOfAreasInFloor:(NSNumber*)ofp_fid;
- (int) numOfFixturesInFloor:(NSNumber*)ofp_fid;
- (int) numOfFixturesInArea:(NSNumber*)ofp_aid;

- (NSString *) setUserInterface;
-(NSString*) getUTCDate:(NSString*)strDate;
-(NSString*) getNoneUTCDate:(NSString*)strDate;
- (int) getStandardWattagesOfFixtureWithType:(NSString*)type Code:(NSString*)code;


+ (NSString*)createFileWithName:(NSString*)fileName FromURL:(NSString*)url;
+ (NSString*)createFileWithName:(NSString*)fileName FromImage:(UIImage*)image;
+ (BOOL)fileExists:(NSString*)fileName;
+ (UIImage *) croppedImage:(UIImage*)image;
+ (void)saveSurveyPictures:(int)surveyId;

typedef NS_ENUM(NSInteger, WATTSWAPTableType) {
    
    WATTSWAPTableTypeFixtureSizeListTable = 0,
    WATTSWAPTableTypeFixtureTypeListTable,
    WATTSWAPTableTypeLenseListTable,
    WATTSWAPTableTypeFixtureControlledListTable,
    WATTSWAPTableTypeFixtureMountingListTable,
    WATTSWAPTableTypeFixtureHeightListTable,
    WATTSWAPTableTypeLampTypeListTable,
    WATTSWAPTableTypeLampCodeListTable,
    WATTSWAPTableTypeLampListTable,
    WATTSWAPTableTypeFixtureBallastTypeTable,
    WATTSWAPTableTypeFixtureBallastFactorListTable,
    WATTSWAPTableTypeFixtureStyleListTable,
    WATTSWAPTableTypeFixtureOptionListTable,
};

@end

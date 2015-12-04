//
//  Global.m
//  Wattswap
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <sys/utsname.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <UIKit/UIKit.h>

#import "CoredataManager.h"

@implementation Global

+ (id)sharedManager
{
    static Global *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super alloc] init];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSNumber *max_survey_id = [prefs objectForKey:@"MAX_SURVEY_ID"];
        NSNumber *max_floor_id = [prefs objectForKey:@"MAX_FLOOR_ID"];
        NSNumber *max_area_id = [prefs objectForKey:@"MAX_AREA_ID"];
        NSNumber *max_fixture_id = [prefs objectForKey:@"MAX_FIXTURE_ID"];
        
        if(max_survey_id == nil) {
            max_survey_id = @0;
            max_floor_id = @0;
            max_area_id = @0;
            max_fixture_id = [NSNumber numberWithInteger:0];
            [prefs setObject:max_survey_id forKey:@"MAX_SURVEY_ID"];
            [prefs setObject:max_floor_id forKey:@"MAX_FLOOR_ID"];
            [prefs setObject:max_area_id forKey:@"MAX_AREA_ID"];
            [prefs setObject:max_fixture_id forKey:@"MAX_FIXTURE_ID"];
            [prefs synchronize];
        }

        sharedManager.max_survey_id = max_survey_id.integerValue;
        sharedManager.max_floor_id = max_floor_id.integerValue;
        sharedManager.max_area_id = max_area_id.integerValue;
        sharedManager.max_fixture_id = max_fixture_id.integerValue;
        
        sharedManager.internetConnected = NO;
        sharedManager.isUploading = NO;
        
        NSNumber *use_volume = [prefs objectForKey:UDS_KEY_USE_VOLUME_FCB];
        NSNumber *use_sound = [prefs objectForKey:UDS_KEY_USE_SOUND_FCB];
        NSNumber *use_vibration = [prefs objectForKey:UDS_KEY_USE_VIBRATION_FCB];
        if(use_volume == nil) {
            use_volume = @0;
            use_sound = @1;
            use_vibration = @0;
            [prefs setObject:use_volume forKey:UDS_KEY_USE_VOLUME_FCB];
            [prefs setObject:use_sound forKey:UDS_KEY_USE_SOUND_FCB];
            [prefs setObject:use_vibration forKey:UDS_KEY_USE_VIBRATION_FCB];
        }
        sharedManager.bUseVolume = use_volume.boolValue;
        sharedManager.bPlaySound = use_sound.boolValue;
        sharedManager.bUseVibration = use_vibration.boolValue;
    });
    return sharedManager;
}

+ (UIImage *) croppedImage:(UIImage*)image
{
    CGFloat minSizeLen = MIN(image.size.width, image.size.height);
    CGFloat x = (image.size.width - minSizeLen) / 2;
    CGFloat y = (image.size.height - minSizeLen) / 2;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect( image.CGImage, CGRectMake(x, y, minSizeLen, minSizeLen));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (NSDate *) getDateFromString:(NSString *)str Format:(NSString*)fmt {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fmt];
    
    NSDate *tempDate = [formatter dateFromString:str];
    return tempDate;
}

- (NSString *) getStringFromDate:(NSDate *)date Format:(NSString*)fmt {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fmt];
    
    NSString *str = [formatter stringFromDate:date];
    return str;
}

- (NSString *) getNewUDID
{
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *guid = (__bridge NSString *)newUniqueIDString;
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    return([guid lowercaseString]);
}

- (NSString*) getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

/*
 member functions for fixture options
 */

- (NSArray*) getFixtureTypes
{
    if(self.fixtureOptions == nil && [self.fixtureOptions count] == 0) return nil;
    NSMutableArray *fixtureTypes = [[NSMutableArray alloc] initWithArray:[self.fixtureOptions objectForKey:@"fixture_types"]];
    
    return (NSArray*)fixtureTypes;
}

- (NSDictionary*) getLampTypeOptionsByTypeName:(NSString*)type
{
    if(self.fixtureOptions == nil && [self.fixtureOptions count] == 0) return nil;
    
    NSMutableArray *lampTypes = [[NSMutableArray alloc] initWithArray:[self.fixtureOptions objectForKey:@"lamp_types"]];
    for(int i=0; i<[lampTypes count]; i++) {
        NSDictionary *dicFixtureOption = lampTypes[i];
        if([[dicFixtureOption objectForKey:@"lamp_type_name"] isEqualToString:type])
        {
            return dicFixtureOption;
        }
    }
    
    return nil;
}

/**
    get maximum value for coredata table's primary key
 */
- (NSNumber*) getMaxSurveyValue:(BOOL)inc
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *max_survey_id = [prefs objectForKey:@"MAX_SURVEY_ID"];
    NSNumber *incVal = [NSNumber numberWithInteger:(max_survey_id.integerValue + 1)];
    
    if(inc) {
        [prefs setObject:incVal forKey:@"MAX_SURVEY_ID"];
        [prefs synchronize];
    }
    return incVal;
}

- (NSNumber*) getMaxFloorValue:(BOOL)inc
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *max_floor_id = [prefs objectForKey:@"MAX_FLOOR_ID"];
    NSNumber *incVal = [NSNumber numberWithInteger:(max_floor_id.integerValue + 1)];
    
    if(inc) {
        [prefs setObject:incVal forKey:@"MAX_FLOOR_ID"];
        [prefs synchronize];
    }
    return incVal;
}

- (NSNumber*) getMaxAreaValue:(BOOL)inc
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *max_area_id = [prefs objectForKey:@"MAX_AREA_ID"];
    NSNumber *incVal = [NSNumber numberWithInteger:(max_area_id.integerValue + 1)];
    
    if(inc) {
        [prefs setObject:incVal forKey:@"MAX_AREA_ID"];
        [prefs synchronize];
    }
    return incVal;
}

- (NSNumber*) getMaxFixtureValue:(BOOL)inc
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *max_fixture_id = [prefs objectForKey:@"MAX_FIXTURE_ID"];
    NSNumber *incVal = [NSNumber numberWithInteger:(max_fixture_id.integerValue + 1)];
    
    if(inc) {
        [prefs setObject:incVal forKey:@"MAX_FIXTURE_ID"];
        [prefs synchronize];
    }
    return incVal;
}

/*
 global functions for manipulating CoreData's internal tables
 */

- (NSString *) setUserInterface {
    
    NSString *storyBoardName = nil;
    /*    if (IS_IPAD_) {
     //iPad
     storyBoardName = @"Main_iPad";
     
     [GlobalData sharedGlobalData].g_strTagPeopleTableViewCell           = @"RFTagPeopleTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strCommentTableViewCell             = @"RFCommentTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strFeedListTableViewCell            = @"RFFeedListTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strCastListTableViewCell            = @"RFCastListTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strPublisherListTableViewCell       = @"RFPublisherListTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strFollowListTableViewCell          = @"RFFollowListTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strFindFriendsPrivateTableViewCell  = @"RFFindFriendsPrivateTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strFindFriendsPublicTableViewCell   = @"RFFindFriendsPublicTableViewCell_iPad";
     [GlobalData sharedGlobalData].g_strProfileHeaderView                = @"RFProfileHeaderView_iPad";
     }
     else*/
    
    if (IS_IPHONE_4_OR_LESS) {     // iphone 3.5 inch
        storyBoardName = @"Main4";
    }
    else if (IS_IPHONE_5) {     // iphone 4 inch
        
        storyBoardName = @"Main";
        
    }
    else if (IS_IPHONE_6) {     // iphone 4.7 inch
        
        storyBoardName = @"Main";
        
    }
    else if (IS_IPHONE_6P) {    // iphone 5.5 inch
        
        storyBoardName = @"Main";
    }
    else {      // default iphone 4 inch
        
        storyBoardName = @"Main4";
    }
    
    return storyBoardName;
}

+ (NSString*)createFileWithName:(NSString*)fileName FromURL:(NSString*)url
{
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    if(image == nil) return nil;
    
    return [Global createFileWithName:fileName FromImage:image];
}

+ (BOOL)fileExists:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    documentsDirectory= [documentsDirectory stringByAppendingPathComponent:@"Wattswap"];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

+ (NSString*)createFileWithName:(NSString*)fileName FromImage:(UIImage*)image
{
    if(image == nil) return @"";
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
    
    // write string to file
    NSString *documentsDirectory= ((Global*)[Global sharedManager]).wattSwapDirectory;

    NSError *error;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success) {
            NSLog(@"Error: %@", [error localizedDescription]);
            return nil;
        }
    }
    
    BOOL succeed = [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    if (succeed){
        return path;
    }
    
    return nil;
}

-(NSString*) getUTCDate:(NSString*)strDate
{
    NSDate *sdate = [self getDateFromString:strDate Format:@"M-d-yyyy"];
    NSString *strScheduled = [self getStringFromDate:sdate Format:@"yyyy-MM-dd"];
    return strScheduled;
}

-(NSString*) getNoneUTCDate:(NSString*)strDate
{
    NSDate *sdate = [self getDateFromString:strDate Format:@"yyyy-MM-dd"];
    NSString *strScheduled = [self getStringFromDate:sdate Format:@"M-d-yyyy"];
    return strScheduled;
}

- (NSString*) getStateNameById:(NSString*)stateID
{
    for (int i = 0;i < [self.states count];i++) {
        if ([[[self.states objectAtIndex:i] objectForKey:@"state_id"] isEqualToString:stateID]) {
            return [[self.states objectAtIndex:i] objectForKey:@"state_name"];
        }
    }
    return nil;
}

- (int) getStateIndexByName:(NSString*)stateName
{
    for (int i = 0;i < [self.states count];i++) {
        if ([[[self.states objectAtIndex:i] objectForKey:@"state_name"] isEqualToString:stateName]) {
            return i;
        }
    }
    return -1;
}

- (NSString*) getStateIdByName:(NSString*)stateName
{
    for (int i = 0;i < [self.states count];i++) {
        if ([[[self.states objectAtIndex:i] objectForKey:@"state_name"] isEqualToString:stateName]) {
            return [[self.states objectAtIndex:i] objectForKey:@"state_id"];
        }
    }
    return STR_ZERO;
}

- (int) numOfAreasInFloor:(NSNumber*)ofp_fid {
    int numOfAreas = 0;
    for (AreaInfo *area in self.areasArray) {
        if (area.ofp_fid.intValue == ofp_fid.intValue) {
            numOfAreas ++;
        }
    }
    return numOfAreas;
}

- (int) numOfFixturesInFloor:(NSNumber*)ofp_fid {
    int numOfFixtures = 0;
    for (FixtureInfo *fixture in self.fixturesArray) {
        if (fixture.ofp_fid.intValue == ofp_fid.intValue) {
            numOfFixtures ++;
        }
    }
    return numOfFixtures;
}

- (int) numOfFixturesInArea:(NSNumber*)ofp_aid {
    int numOfFixtures = 0;
    for (FixtureInfo *fixture in self.fixturesArray) {
        if (fixture.ofp_aid.intValue == ofp_aid.intValue) {
            numOfFixtures ++;
        }
    }
    return numOfFixtures;
}

- (int) getStandardWattagesOfFixtureWithType:(NSString*)type Code:(NSString*)code
{
//    NSArray *fixtureCodes = nil;
//    for(int i=0; i<[self.fixtureOptions count]; i++) {
//        NSDictionary *fixtureType = [self.fixtureOptions objectAtIndex:i];
//        if([[fixtureType objectForKey:@"fixture_type_name"] isEqualToString:type]) {
//            fixtureCodes = [fixtureType objectForKey:@"codes"];
//            break;
//        }
//    }
//    
//    if(fixtureCodes != nil) {
//        for(int j=0; j<[fixtureCodes count]; j++) {
//            NSDictionary *fixtureCode = [fixtureCodes objectAtIndex:j];
//            if([[fixtureCode objectForKey:@"fixture_code_name"] isEqualToString:code]) {
//                NSString *strWattage = [fixtureCode objectForKey:@"wattages"];
//                return strWattage.intValue;
//            }
//        }
//    }
    
    return 0;
}

+ (void)saveSurveyPictures:(int)surveyId {
    
}

@end

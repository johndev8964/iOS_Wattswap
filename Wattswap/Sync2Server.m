//
//  Sync2Server.m
//  Wattswap
//
//  Created by MY on 8/28/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "Sync2Server.h"
#import "APIService.h"
#import "CoredataManager.h"

#import <AFHTTPRequestOperation.h>

@implementation Sync2Server

static Sync2Server *syncManager = nil;

+ (instancetype) sharedSyncManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        syncManager = [[super alloc] init];
    });
    return syncManager;
}

-(void) dismissProgress {
    self.iRequestCount--;
    if(self.iRequestCount <= 0)
        [SVProgressHUD dismiss];
}

- (void) loadFixtureOptions
{
    Global *global = [Global sharedManager];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *jsonResult = [prefs objectForKey:@"FIXTURE_OPTIONS"];
    if(jsonResult != nil) global.fixtureOptions = [jsonResult objectForKey:@"data"];
    
    [SVProgressHUD showWithStatus:@"loading..." maskType:SVProgressHUDMaskTypeClear];
    [[APIService sharedManager] getFixtureOptions:^(NSDictionary *result, NSError *error) {
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSDictionary *optionData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"success"]) {
                global.fixtureOptions = optionData;
            }
        }
        
        if(global.internetConnected && global.fixtureOptions == nil)
            [self loadFixtureOptions];
    }];
}

- (void) loadStateOptions
{
    Global *global = [Global sharedManager];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *jsonResult = [prefs objectForKey:@"STATES"];
    if(jsonResult != nil) global.states = [jsonResult objectForKey:@"data"];
    
    [SVProgressHUD showWithStatus:@"loading..." maskType:SVProgressHUDMaskTypeClear];
    
    [[APIService sharedManager] getStates:^(NSDictionary *result2, NSError *error2) {
        if(error2 == nil) {
            NSString *statusCode2 = [result2 objectForKey:@"status"];
            NSArray *stateData = [result2 objectForKey:@"data"];
            if ([statusCode2 isEqualToString:@"Success"]) {
                global.states = stateData;
            }
        }
        
        if(global.internetConnected && global.states == nil)
            [self loadStateOptions];
    }];
}

- (void) loadConversionList {
    
    Global *global = [Global sharedManager];
    [SVProgressHUD showWithStatus:@"loading..." maskType:SVProgressHUDMaskTypeClear];
    [[APIService sharedManager] getRetrofits:^(NSDictionary *result, NSError *error) {
        if(error == nil) {
            
            NSString *statusCode = [result objectForKey:@"status"];
            NSArray *conversionData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"Success"]) {
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                
                [APIService deleteObjectFromCoreData:@"RetrofitInfo" Condition:@"retrofit_id!=%@" FieldValue:0];
                for(int i=0; i<[conversionData count]; i++) {
                    NSDictionary *conversion = [conversionData objectAtIndex:i];
                    RetrofitInfo *retrofitInfo = [NSEntityDescription insertNewObjectForEntityForName:@"RetrofitInfo" inManagedObjectContext:coreDataContext];
                    [retrofitInfo initWithDict:conversion];
                    
                    NSString *fullImagePath = [[[Global sharedManager] wattSwapDirectory] stringByAppendingPathComponent: CONVERSION_CANDI_IMAGE_NAME(retrofitInfo.retrofit_id.stringValue)];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if([fileManager fileExistsAtPath:fullImagePath] == NO)
                    {
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:retrofitInfo.retrofit_image]];
                        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

                            [Global createFileWithName:CONVERSION_CANDI_IMAGE_NAME(retrofitInfo.retrofit_id.stringValue) FromImage:responseObject];
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Image error: %@", error);
                        }];
                        [requestOperation start];
                    }
                }
                [coreDataContext save:&error];
            }
        }
        
        NSArray *conversions = [APIService getObjectsFromCoreData:@"RetrofitInfo"];
        if(global.internetConnected && conversions == nil)
            [self loadConversionList];
    }];
}

- (BOOL) startSync2RtDB {
    
    if(self.isProcessing) {
        [self endProcessingWithStatus2RtDB:@"error" Error:nil];
        return NO;
    }
    
    self.isProcessing = YES;
    self.iRequestCount = 0;
    
    [self loadStateOptions];
    [self loadFixtureOptions];
    [self loadConversionList];
    
    Global *global = [Global sharedManager];
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSString *tzName = [timeZone abbreviation];
    NSDictionary *params = @{@"supervisor_id":global.supervisorID, @"timeZone":tzName};
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    [SVProgressHUD showWithStatus:@"loading..." maskType:SVProgressHUDMaskTypeClear];
    [[APIService sharedManager] getSurveysFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
        if (error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSMutableDictionary *surveyData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"success"]) {
                
                NSString *timeDiff = [result objectForKey:@"time_diff"];
                global.g_timeDiff2Server = timeDiff.intValue;
                NSInteger maxSurveyId = [global getMaxSurveyValue:NO].integerValue;
                
                NSArray *surveyObjects = [APIService getObjectsFromCoreData:@"SurveyInfo"];
                if(surveyObjects != nil) {
                    for(int i=0; i<[surveyObjects count]; i++) {
                        SurveyInfo *surveyInfo = [surveyObjects objectAtIndex:i];
                        int ex_survey_id = surveyInfo.sid.intValue;
                        BOOL found = NO;
                        for (NSDictionary *survey in surveyData)
                        {
                            NSString *strSurveyId = [survey objectForKey:@"survey_id"];
                            int survey_id = strSurveyId.intValue;
                            if(survey_id != 0) {
                                if(survey_id == ex_survey_id) {
                                    found = YES;
                                    break;
                                }
                            }
                        }
                        if(found == NO) {
                            NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                            NSNumber *ofp_surveyId = surveyInfo.ofp_sid;
                            [APIService deleteObjectFromCoreData:@"FixtureInfo" Condition:@"ofp_sid==%@" FieldValue:ofp_surveyId.stringValue];
                            [APIService deleteObjectFromCoreData:@"AreaInfo" Condition:@"ofp_sid==%@" FieldValue:ofp_surveyId.stringValue];
                            [APIService deleteObjectFromCoreData:@"FloorInfo" Condition:@"ofp_sid==%@" FieldValue:ofp_surveyId.stringValue];
                            [coreDataContext deleteObject:surveyInfo];
                            
                            NSError *error1;
                            [coreDataContext save:&error1];
                        }
                    }
                }
                
                int countOfSurveys = (int)[surveyData count], curSurveyIndex = 0;
                for (NSDictionary *survey in surveyData)
                {
                    curSurveyIndex ++;
                    SurveyInfo *newSurvey = nil;
                    NSArray *candis = [APIService getObjectsFromCoreData:@"SurveyInfo" IDName:@"sid" IDValue:[survey objectForKey:@"survey_id"]];
                    
                    NSString* lastModified = [survey objectForKey:@"last_modified"];
                    NSDate *svrTime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
                    if(candis != nil)
                    {
                        newSurvey = [candis objectAtIndex:0];
                        if(newSurvey.stime < svrTime) {
                            [newSurvey initWithDict:survey];
                        }
                    }
                    else {
                        newSurvey = [NSEntityDescription insertNewObjectForEntityForName:@"SurveyInfo" inManagedObjectContext:coreDataContext];
                        
                        newSurvey.supervisor_id = global.supervisorID;
                        newSurvey.ofp_sid = [global getMaxSurveyValue:YES];
                        [newSurvey initWithDict:survey];
                        
                        NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newSurvey.path]];
                        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                        self.iRequestCount ++;
                        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"Response: %@", responseObject);
                            UIImage *image = responseObject;
                            newSurvey.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"survey_%@.png", newSurvey.ofp_sid] FromImage:image];
                            
                            NSError *error;
                            [coreDataContext save:&error];
                            [self dismissProgress];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Image error: %@", error);
                            [self dismissProgress];
                        }];
                        
                        [requestOperation start];
                        
                        NSError *error1;
                        if(NO == [coreDataContext save:&error1]) {
                            NSLog(@"Error in core data operation as the following\n%@.", error1.description);
                            global.max_survey_id = maxSurveyId;
                        }
                    }

                    [coreDataContext save:&error];
                    
                    [self updateServeryTree:newSurvey IsLastSurvey:(countOfSurveys == curSurveyIndex)];
                }
            }
            else {
                [self endProcessingWithStatus2RtDB:@"error" Error:error];
            }
        }
        else
        {
            [self endProcessingWithStatus2RtDB:@"error" Error:error];
        }
    }];
    
    return YES;
}

-(void) updateServeryTree:(SurveyInfo*)surveyInfo IsLastSurvey:(BOOL)lastSurvey {
    
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    NSDictionary *params = @{@"survey_id": surveyInfo.sid};
    [[APIService sharedManager] getSurveyTreeFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
        
        NSString *statusCode = @"Error";
        if(error == nil) {
            statusCode = [result objectForKey:@"status"];
            NSMutableDictionary *surveyData = [result objectForKey:@"data"];
            if ([statusCode isEqualToString:@"success"])
            {
                NSArray *floors = [surveyData objectForKey:@"floors"];
                for(int f=0; f<[floors count]; f++) {
                    
                    FloorInfo *floorInfo = nil;
                    NSDictionary *floorDict = [floors objectAtIndex:f];
                    NSArray *candis = [APIService getObjectsFromCoreData:@"FloorInfo" IDName:@"fid" IDValue:[floorDict objectForKey:@"floor_id"]];
                    if(candis != nil) floorInfo = [candis objectAtIndex:0];
                    if( floorInfo == nil)
                    {
                        floorInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
                        
                        floorInfo.ofp_sid = surveyInfo.ofp_sid;
                        floorInfo.ofp_fid = [global getMaxFloorValue:YES];
                        [floorInfo initWithDict:floorDict];
                    }
                    else {
                        NSString *lastModified = [floorDict objectForKey:@"last_modified"];
                        NSDate *stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
                        if(floorInfo.stime.timeIntervalSince1970 < stime.timeIntervalSince1970) {
                            [floorInfo initWithDict:floorDict];
                        }
                    }
                    
                    NSArray *areas = [surveyData objectForKey:@"areas"];
                    for(int a=0; a < [areas count]; a ++) {
                        
                        AreaInfo *areaInfo = nil;
                        NSDictionary *areaDict = [areas objectAtIndex:a];
                        
                        NSNumber *a_fid = NFS([areaDict objectForKey:@"floor_id"]);
                        if(a_fid.intValue != floorInfo.fid.intValue) continue;
                        
                        NSArray *candis1 = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"aid" IDValue:[areaDict objectForKey:@"area_id"]];
                        if(candis1 != nil) areaInfo = [candis1 objectAtIndex:0];
                        if( areaInfo == nil)
                        {
                            areaInfo = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
                            
                            areaInfo.ofp_sid = surveyInfo.ofp_sid;
                            areaInfo.ofp_fid = floorInfo.ofp_fid;
                            areaInfo.ofp_aid = [global getMaxAreaValue:YES];
                            [areaInfo initWithDict:areaDict];
                        }
                        else {
                            NSString *lastModified = [areaDict objectForKey:@"last_modified"];
                            NSDate *stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
                            if(areaInfo.stime.timeIntervalSince1970 < stime.timeIntervalSince1970) {
                                [areaInfo initWithDict:areaDict];
                            }
                        }
                        
                        NSArray *fixtures = [surveyData objectForKey:@"fixtures"];
                        for(int x = 0; x < [fixtures count]; x++) {
                            
                            FixtureInfo *fixtureInfo = nil;
                            NSDictionary *fixtureDict = [fixtures objectAtIndex:x];
                            NSNumber *f_fid = NFS([fixtureDict objectForKey:@"floor_id"]);
                            NSNumber *f_aid = NFS([fixtureDict objectForKey:@"area_id"]);
                            if(f_fid.intValue != floorInfo.fid.intValue || f_aid.intValue != areaInfo.aid.intValue) continue;
                            NSArray *candis2 = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"fixtureid" IDValue:[fixtureDict objectForKey:@"fixture_id"]];
                            if(candis2 != nil) fixtureInfo = [candis2 objectAtIndex:0];
                            if( fixtureInfo == nil)
                            {
                                fixtureInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
                                
                                fixtureInfo.ofp_sid = surveyInfo.ofp_sid;
                                fixtureInfo.ofp_fid = floorInfo.ofp_fid;
                                fixtureInfo.ofp_aid = areaInfo.ofp_aid;
                                fixtureInfo.ofp_fixtureid = [global getMaxFixtureValue:YES];
                                [fixtureInfo initWithDict:fixtureDict];

                                NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fixtureInfo.path]];
                                AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                                requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                                self.iRequestCount ++;
                                [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"Response: %@", responseObject);
                                    UIImage *image = responseObject;
                                    fixtureInfo.ofp_path = [Global createFileWithName:[NSString stringWithFormat:@"fixture_%@.png", fixtureInfo.ofp_fixtureid] FromImage:image];
                                    
                                    NSError *error;
                                    [coreDataContext save:&error];
                                    [self dismissProgress];
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"Image error: %@", error);
                                    [self dismissProgress];
                                }];
                                
                                [requestOperation start];
                            }
                            else {
                                NSString *lastModified = [fixtureDict objectForKey:@"create_ts"];
                                NSDate *stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
                                if(fixtureInfo.stime.timeIntervalSince1970 < stime.timeIntervalSince1970) {
                                    [fixtureInfo initWithDict:fixtureDict];
                                }
                            }
                            
                            [coreDataContext save:&error];
                        }
                    }
                }
                
                [coreDataContext save:&error];
            }
        }
        if(lastSurvey) {
            [self endProcessingWithStatus2RtDB:statusCode Error:error];
        }
    }];
}

- (void) endProcessingWithStatus2RtDB:(NSString*)status Error:(NSError*)error {
    self.isProcessing = NO;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinished2RtDBWithResult:Error:)]) {
        [self.delegate didFinished2RtDBWithResult:status Error:error];
    }
    if(self.iRequestCount <=0)
        [SVProgressHUD dismiss];
}


- (BOOL)startSync2LcDB {
    
    if(self.isUploading) {
        [self endProcessingWithStatus2RtDB:@"error" Error:nil];
        return NO;
    }
    self.isUploading = YES;
    
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    
    // add operations
    NSArray *aryFixture = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"fixtureid" IDValue:STR_ZERO];
    NSArray *aryArea = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"aid" IDValue:STR_ZERO];
    NSArray *aryFloor = [APIService getObjectsFromCoreData:@"FloorInfo" IDName:@"fid" IDValue:STR_ZERO];
    NSArray *arySurvey = [APIService getObjectsFromCoreData:@"SurveyInfo" IDName:@"sid" IDValue:STR_ZERO];
    
    if(aryFixture != nil) {
        for(int i=0; i<[aryFixture count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            FixtureInfo *fixture = [aryFixture objectAtIndex:i];
            if(fixture.aid.intValue == 0) continue;
            [self processRemoteRequestForAddFixture:fixture];
        }
    }
    
    if(aryArea != nil) {
        for(int i=0; i<[aryArea count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            AreaInfo *area = [aryArea objectAtIndex:i];
            if(area.fid.intValue == 0) continue;
            [self processRemoteRequestForAddArea:area];
        }
    }
    
    if(aryFloor != nil) {
        for(int i=0; i<[aryFloor count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            FloorInfo *floor = [aryFloor objectAtIndex:i];
            if(floor.sid.intValue == 0) continue;
            [self processRemoteRequestForAddFloor:floor];
        }
    }
    
    if(arySurvey != nil) {
        for(int i=0; i<[arySurvey count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            SurveyInfo *survey = [arySurvey objectAtIndex:i];
            [self processRemoteRequestForAddSurvey:survey];
        }
    }
    
    // deleting-operations
    arySurvey = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Del_Survey"];
    if(arySurvey != nil) {
        for(int i=0; i<[arySurvey count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [arySurvey objectAtIndex:i];
            NSDictionary *params = @{@"survey_id":data.obj_id};
            [[APIService sharedManager] deleteSurveyFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"Success"])
                {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    aryFloor = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Del_Floor"];
    if(aryFloor != nil) {
        for(int i=0; i<[aryFloor count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [aryFloor objectAtIndex:i];
            NSDictionary *params = @{@"floor_id":data.obj_id};
            [[APIService sharedManager] deleteFloorFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"Success"])
                {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    aryArea = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Del_Area"];
    if(aryArea != nil) {
        for(int i=0; i<[aryArea count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [aryArea objectAtIndex:i];
            NSDictionary *params = @{@"area_id":data.obj_id};
            [[APIService sharedManager] deleteAreaFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"Success"])
                {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    aryFixture = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Del_Fixture"];
    if(aryFixture != nil) {
        for(int i=0; i<[aryFixture count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [aryFixture objectAtIndex:i];
            NSDictionary *params = @{@"fixture_id":data.obj_id};
            [[APIService sharedManager] deleteFixtureFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"Success"])
                {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    // saving-operations
    arySurvey = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Unsaved_Survey"];
    if(arySurvey != nil) {
        for(int i=0; i<[arySurvey count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [arySurvey objectAtIndex:i];
            NSArray *surveys = [APIService getObjectsFromCoreData:@"SurveyInfo" IDName:@"ofp_sid" IDValue:data.obj_id.stringValue];
            if(surveys == nil || [surveys count] == 0) continue;
            
            NSDictionary *params = [self getParamsOfSurvey:[surveys objectAtIndex:0]];
            [[APIService sharedManager] saveSurvey2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"success"]) {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    aryFloor = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Unsaved_Floor"];
    if(aryFloor != nil) {
        for(int i=0; i<[aryFloor count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [aryFloor objectAtIndex:i];
            NSArray *floors = [APIService getObjectsFromCoreData:@"FloorInfo" IDName:@"ofp_fid" IDValue:data.obj_id.stringValue];
            if(floors == nil || [floors count] == 0) continue;
            
            FloorInfo *floor = [floors objectAtIndex:0];
            NSDictionary *params = @{@"floor_id":floor.fid, @"floor_name":floor.fdesc};
            [[APIService sharedManager] saveFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"success"]) {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    aryArea = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Unsaved_Area"];
    if(aryArea != nil) {
        for(int i=0; i<[aryArea count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [aryArea objectAtIndex:i];
            NSArray *areas = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"ofp_aid" IDValue:data.obj_id.stringValue];
            if(areas == nil || [areas count] == 0) continue;
            
            AreaInfo *area = [areas objectAtIndex:0];
            NSDictionary *params = @{@"area_id":area.aid, @"area_name":area.adesc};
            [[APIService sharedManager] saveArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"success"]) {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    aryFixture = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" StringValue:@"Unsaved_Fixture"];
    if(aryFixture != nil) {
        for(int i=0; i<[aryFixture count]; i++)
        {
            if(global.internetConnected == NO) break;
            
            OperationInfo *data = [aryFixture objectAtIndex:i];
            NSArray *fixtures = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"ofp_fixtureid" IDValue:data.obj_id.stringValue];
            if(fixtures == nil || [fixtures count] == 0) continue;
            
            NSDictionary *params = [self getParamsOfSurvey:[fixtures objectAtIndex:0]];
            [[APIService sharedManager] saveFixture2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                if(error != nil && [[result objectForKey:@"status"] isEqualToString:@"success"]) {
                    [coreDataContext deleteObject:data];
                    [coreDataContext save:&error];
                }
            }];
        }
    }
    
    NSString *strWhere = [NSString stringWithFormat:@"type == 'Seq_Floor' or type == 'Seq_Area' or type == 'Seq_Fixture'"];
    NSArray *arySeqOperations = [APIService getObjectsFromCoreData:@"OperationInfo" Where:strWhere];
    if(arySeqOperations != nil && [arySeqOperations count] > 0) {
        for(int i=0; i<[arySeqOperations count]; i++) {
            OperationInfo *opr = [arySeqOperations objectAtIndex:i];
            
            NSDictionary *params = @{@"obj_type":opr.type, @"value":opr.value};
            [[APIService sharedManager] changeSequence2ServerForObject:params onCompletion:^(NSDictionary *result, NSError *error) {
                if (error == nil) {
                    NSString *statusCode = [result objectForKey:@"status"];
                    if ([statusCode isEqualToString:@"success"]) {
                        [coreDataContext deleteObject:opr];
                        [coreDataContext save:&error];
                    }
                }
            }];
        }
    }
    
    dispatch_async(APP_CUSTOM_QUEUE, ^{

        int cnt = -1;
        NSDate *updatedTime = [NSDate date];
        
        do {
        
            NSArray *aryObjs = [APIService getObjectsFromCoreData:@"OperationInfo"];
            if(cnt != [aryObjs count]) {
                updatedTime = [NSDate date];
                cnt = (int)[aryObjs count];
            }
            
            if(aryObjs == nil)
                cnt = 0;
            else
                cnt = (int)[aryObjs count];
            
            if(global.internetConnected == NO) break;
            
            NSTimeInterval tiFromUpdated = [[NSDate date] timeIntervalSinceDate: updatedTime];
            if(tiFromUpdated > 120) {
                break;
            }
            
        } while (cnt > 0);
        
        self.isUploading = NO;
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinished2RtDBWithResult:Error:)]) {
            [self.delegate didFinished2LcDBWithResult:@"success" Error:nil];
        }
        
    });
    
    return YES;
}

- (void) processRemoteRequestForAddSurvey:(SurveyInfo*)survey
{
    NSString *base64Image = @"";
    if([survey.ofp_path isEqualToString:@""] == NO)
    {
        NSURL *url = [NSURL fileURLWithPath:survey.ofp_path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil) {
            base64Image = [data base64EncodedString];
        }
    }
    
    Global *global = [Global sharedManager];
    NSDictionary *params = @{@"supervisor_id":survey.supervisor_id, @"survey_facility_name":survey.sname , @"survey_facility_add_l1":survey.addressline1, @"survey_facility_add_l2":survey.addressline2, @"survey_facility_city":survey.city, @"state_id":survey.state, @"survey_facility_zip":survey.zip, @"survey_contact_name":survey.cname, @"survey_contact_phone":survey.cphone, @"survey_contact_email":survey.cemail, @"survey_schedule_date":[global getStringFromDate:survey.scheduled Format:@"yyyy-MM-dd HH:mm:ss"], @"survey_note":survey.note, @"survey_building_units":survey.bunit, @"survey_building_type":survey.btype, @"survey_reffered_by":survey.breff, @"survey_sq_foot":survey.btototalfutage, @"survey_utility_company":survey.butilitycompany, @"survey_account_no":survey.accountnumber, @"survey_images_b64":base64Image, @"survey_rate_per_watt":survey.rateperwatt};
    
    [[APIService sharedManager] addSurvey2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSArray* arrayData = [result objectForKey:@"data"];
            
            if ([statusCode isEqualToString:@"Success"]) {
                NSDictionary *data = arrayData[0];
                survey.sid = NFS([data objectForKey:@"survey_id"]);
                survey.path = ISNull([data objectForKey:@"survey_image_path"]) ? @"":[data objectForKey:@"survey_image_path"];
                survey.stime = [global getDateFromString:[data objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                
                NSArray *arrayFloor = [APIService getObjectsFromCoreData:@"FloorInfo" IDName:@"ofp_sid" IDValue:survey.ofp_sid.stringValue];
                for(int i=0; i<[arrayFloor count]; i++) {
                    FloorInfo *floor = (FloorInfo*)[arrayFloor objectAtIndex:i];
                    floor.sid = survey.sid;
                    [self processRemoteRequestForAddFloor:floor];
                }
                
                NSError *error;
                [coreDataContext save:&error];
            }
        }
    }];
}

- (void) processRemoteRequestForAddFloor:(FloorInfo*)floor
{
    NSDictionary *params = @{@"survey_id":floor.sid, @"floor_name":floor.fdesc};
    [[APIService sharedManager] addFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
        
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSArray* arrayData = [result objectForKey:@"data"];
            NSDictionary *data = arrayData[0];
            
            if ([statusCode isEqualToString:@"success"]) {
                Global *global = [Global sharedManager];
                floor.fid = NFS([data objectForKey:@"floor_id"]);
                floor.stime = [global getDateFromString:[data objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                
                NSArray *arrayArea = [APIService getObjectsFromCoreData:@"AreaInfo" IDName:@"ofp_fid" IDValue:floor.ofp_fid.stringValue];
                for(int i=0; i<[arrayArea count]; i++) {
                    AreaInfo *area = (AreaInfo*)[arrayArea objectAtIndex:i];
                    area.sid = floor.sid;
                    area.fid = floor.fid;
                    [self processRemoteRequestForAddArea:area];
                }
                
                NSError *error;
                [coreDataContext save:&error];
            }
        }
    }];
}

- (void) processRemoteRequestForAddArea:(AreaInfo*)area
{
    NSDictionary *params = @{@"survey_id":area.sid, @"floor_id":area.fid, @"area_name":area.adesc};
    [[APIService sharedManager] addArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSArray* arrayData = [result objectForKey:@"data"];
            NSDictionary *data = arrayData[0];
            
            if ([statusCode isEqualToString:@"success"]) {
                Global *global = [Global sharedManager];
                area.aid = NFS([data objectForKey:@"area_id"]);
                area.stime = [global getDateFromString:[data objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                NSArray *arrayFixture = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"ofp_aid" IDValue:area.ofp_aid.stringValue];
                for(int i=0; i<[arrayFixture count]; i++) {
                    FixtureInfo *fixture = (FixtureInfo*)[arrayFixture objectAtIndex:i];
                    fixture.sid = area.sid;
                    fixture.fid = area.fid;
                    fixture.aid = area.aid;
                    [self processRemoteRequestForAddFixture:fixture];
                }
                NSError *error;
                [coreDataContext save:&error];
            }
        }
    }];
}

- (void) processRemoteRequestForAddFixture:(FixtureInfo*)fixture
{
    NSString *base64Image = @"";
    if([fixture.ofp_path isEqualToString:@""] == NO)
    {
        NSURL *url = [NSURL fileURLWithPath:fixture.ofp_path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil) {
            base64Image = [data base64EncodedString];
        }
    }
    
    NSDictionary *params = @{@"supervisor_id":fixture.supervisor_id, @"survey_id":fixture.sid, @"floor_id":fixture.fid, @"area_id":fixture.aid, @"count":fixture.fixturecnt, @"type":fixture.fixturetype, @"code":fixture.lampcode, @"style":fixture.style, @"mounting":fixture.mounting, @"controlled":fixture.control, @"option":fixture.option, @"height":fixture.height, @"hrs_per_day":fixture.hoursperday, @"days_per_week":fixture.daysperweek, @"notes":fixture.note, @"ballast":fixture.ballasttype, @"factor":fixture.ballastfactor, @"bulbs_per_fixture":fixture.bulbsperfixture, @"watts_per_bulb":fixture.wattsperbulb, @"fixture_images_b64":base64Image, @"replacement_id":fixture.replacement_id, @"fixture_size":fixture.fixturesize, @"lense":fixture.lense, @"lamp_type":fixture.lamptype, @"lamp":fixture.lamp, @"lamp_real_wattage":fixture.realwatts};
    
    [[APIService sharedManager] addFixture2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
        
        if(error == nil) {
            NSString *statusCode = [result objectForKey:@"status"];
            NSArray* arrayData = [result objectForKey:@"data"];
            NSDictionary *data = arrayData[0];
            
            if ([statusCode isEqualToString:@"success"]) {
                fixture.fixtureid = NFS([data objectForKey:@"fixture_id"]);
                fixture.path = ISNull([data objectForKey:@"fixture_image"]) ? @"":[data objectForKey:@"fixture_image"];
                Global *global = [Global sharedManager];
                fixture.stime = [global getDateFromString:[data objectForKey:@"create_ts"] Format:@"yyyy-MM-dd HH:mm:ss"];
                
                NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
                NSError *error;
                [coreDataContext save:&error];
            }
        }
    }];
}

- (NSDictionary*)getParamsOfSurvey:(SurveyInfo*)surveyInfo
{
    NSString *base64Image = @"";
    if([surveyInfo.ofp_path isEqualToString:@""] == NO)
    {
        UIImage *img = [UIImage imageWithContentsOfFile:surveyInfo.ofp_path];
        NSData *data = UIImageJPEGRepresentation(img, 0.7f);
        if (data != nil) {
            base64Image = [data base64EncodedString];
        }
    }
    
    Global *global = [Global sharedManager];
    NSDictionary *params = @{@"survey_id":surveyInfo.sid, @"survey_facility_name":surveyInfo.sname,@"survey_facility_add_l1":surveyInfo.addressline1,@"survey_facility_add_l2":surveyInfo.addressline2, @"survey_facility_city":surveyInfo.city, @"state_id":surveyInfo.state,@"survey_facility_zip":surveyInfo.zip,@"survey_contact_name":surveyInfo.cname,@"survey_contact_phone":surveyInfo.cphone, @"survey_contact_email":surveyInfo.cemail,@"survey_schedule_date":[global getStringFromDate:surveyInfo.scheduled Format:@"yyyy-MM-dd HH:mm:ss"], @"survey_note":surveyInfo.note,@"survey_building_units":surveyInfo.bunit,@"survey_building_type":surveyInfo.btype,@"survey_reffered_by":surveyInfo.breff,@"survey_sq_foot":surveyInfo.btototalfutage,@"survey_utility_company":surveyInfo.butilitycompany,@"survey_account_no":surveyInfo.accountnumber, @"survey_images_b64":base64Image, @"survey_rate_per_watt":surveyInfo.rateperwatt};
    
    return params;
}

- (NSDictionary*)getParamsOfFixture:(FixtureInfo*)fixture
{
    NSString *base64Image = @"";
    if([fixture.ofp_path isEqualToString:@""] == NO)
    {
        UIImage *img = [UIImage imageWithContentsOfFile:fixture.ofp_path];
        NSData *data = UIImageJPEGRepresentation(img, 0.7f);
        if (data != nil) {
            base64Image = [data base64EncodedString];
        }
    }
    
    Global *global = [Global sharedManager];
    NSDictionary *params = @{@"supervisor_id":global.supervisorID, @"survey_id":fixture.sid, @"floor_id":fixture.fid, @"area_id":fixture.aid, @"fixture_id":fixture.fixtureid, @"count":fixture.fixturecnt, @"type":fixture.fixturetype, @"code":fixture.lampcode, @"style":fixture.style, @"mounting":fixture.mounting, @"controlled":fixture.control, @"option":fixture.option, @"height":fixture.height, @"hrs_per_day":fixture.hoursperday, @"days_per_week":fixture.daysperweek, @"notes":fixture.note, @"ballast":fixture.ballasttype, @"factor":fixture.ballastfactor, @"bulbs_per_fixture":fixture.bulbsperfixture, @"watts_per_bulb":fixture.wattsperbulb, @"fixture_images_b64":base64Image, @"replacement_id":fixture.replacement_id, @"fixture_size":fixture.fixturesize, @"lense":fixture.lense, @"lamp_type":fixture.lamptype, @"lamp":fixture.lamp, @"lamp_real_wattage":fixture.realwatts};
    
    return params;
}


@end

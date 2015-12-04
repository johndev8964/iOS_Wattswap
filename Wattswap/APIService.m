//
//  APIService.m
//  Wattswap
//
//  Created by User on 5/13/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "APIService.h"
#import "Constants.h"
#import "CoredataManager.h"

#import <CoreData/NSEntityDescription.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation APIService

static int stc_request_count;

+ (id)sharedManager
{
    static APIService *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super alloc] init];
        stc_request_count = 0;
    });
    return sharedManager;
}

+ (BOOL)isCompleted
{
    return (stc_request_count == 0);
}

+ (NSArray*) getObjectsFromCoreData:(NSString*)entityName IDName:(NSString*)idName StringValue:(NSString*)idVal
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:coreDataContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"%@ == '%@'", idName, idVal]];
    [fetchRequest setPredicate:predicate];
    NSError* error;
    NSArray* widgets = [coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (widgets == nil || [widgets count] == 0) return nil;
    
    return widgets;
}

+ (NSArray*) getObjectsFromCoreData:(NSString*)entityName IDName:(NSString*)idName IDValue:(NSString*)idVal
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:coreDataContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"%@ == %@", idName, idVal]];
    [fetchRequest setPredicate:predicate];
    NSError* error;
    NSArray* widgets = [coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (widgets == nil || [widgets count] == 0) return nil;
    
    return widgets;
}

+ (NSArray*) getObjectsFromCoreData:(NSString*)entityName
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:coreDataContext];
    
    [fetchRequest setEntity:entity];
    
    NSError* error;
    NSArray* widgets = [coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (widgets == nil || [widgets count] == 0) return nil;
    
    return widgets;
}

+ (NSArray*) getObjectsFromCoreData:(NSString *)entityName Where:(NSString*)where {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:coreDataContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:where];
    [fetchRequest setPredicate:predicate];
    NSError* error;
    NSArray* widgets = [coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (widgets == nil || [widgets count] == 0) return nil;
    
    return widgets;
}
/*
 where : @"ofp_sid == 234"
 data : @{@"sid" : @"67"}
 */
+ (BOOL) updateWithCondition:(NSString*)entityName Where:(NSString*)where Data:(NSDictionary*)data
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:coreDataContext];
 
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        // Initialize Batch Update Request
        NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntity:entityDescription];
        
        // Configure Fitler Condition
        NSPredicate* predicate = [NSPredicate predicateWithFormat: where];
        [batchUpdateRequest setPredicate:predicate];

        // Configure Batch Update Request
        [batchUpdateRequest setResultType:NSUpdatedObjectIDsResultType];
        [batchUpdateRequest setPropertiesToUpdate:data];
        

        // Execute Batch Request
        NSError *batchUpdateRequestError = nil;
        NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[coreDataContext executeRequest:batchUpdateRequest error:&batchUpdateRequestError];
        
        if (batchUpdateRequestError)
        {
            NSLog(@"Unable to execute batch update request.");
            NSLog(@"%@, %@", batchUpdateRequestError, batchUpdateRequestError.localizedDescription);
            return NO;
        }

        NSError *error;
        return [coreDataContext save:&error];
        //    else {
//        // Extract Object IDs
//        NSArray *objectIDs = batchUpdateResult.result;
//        
//        for (NSManagedObjectID *objectID in objectIDs) {
//            // Turn Managed Objects into Faults
//            NSManagedObject *managedObject = [coreDataContext objectWithID:objectID];
//            
//            if (managedObject) {
//                [coreDataContext refreshObject:managedObject mergeChanges:NO];
//            }
//        }
//    }
    }
    else
    {
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:where];
        [fetchRequest setPredicate:predicate];
        NSError* error;
        NSArray* widgets = [coreDataContext executeFetchRequest:fetchRequest error:&error];
        
        int entityType = 0;
        if([entityName isEqualToString:@"FloorInfo"])
            entityType = 1;
        else if([entityName isEqualToString:@"AreaInfo"])
            entityType = 2;
        else // fixture
            entityType = 3;
        
        if (widgets != nil)
        {
            for(int i=0; i<[widgets count]; i++)
            {
                switch (entityType) {
                    case 1: //floor
                    {
                        FloorInfo *survey = (FloorInfo*)[widgets objectAtIndex:i];
                        NSString *val = [data objectForKey:@"sid"];
                        if(val != nil) survey.sid = [NSNumber numberWithInt:val.intValue];
                        break;
                    }
                    case 2: // area
                    {
                        AreaInfo *area = (AreaInfo*)[widgets objectAtIndex:i];
                        NSString *val = [data objectForKey:@"sid"];
                        if(val != nil) area.sid = [NSNumber numberWithInt:val.intValue];
                        else {
                            val = [data objectForKey:@"fid"];
                            if(val != nil) area.fid = [NSNumber numberWithInt:val.intValue];
                        }
                        
                        break;
                    }
                    case 3: // fixture
                    {
                        FixtureInfo *fixture = (FixtureInfo*)[widgets objectAtIndex:i];
                        NSString *val = [data objectForKey:@"sid"];
                        if(val != nil) fixture.sid = [NSNumber numberWithInt:val.intValue];
                        else {
                            val = [data objectForKey:@"fid"];
                            if(val != nil) fixture.fid = [NSNumber numberWithInt:val.intValue];
                            else {
                                val = [data objectForKey:@"aid"];
                                if(val != nil) fixture.aid = [NSNumber numberWithInt:val.intValue];
                            }
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            
            return [coreDataContext save:&error];
        }
    }
    
    return YES;
}

// delete for any table's records matching of condition
+ (void) deleteObjectFromCoreData:(NSString*)entityName Condition:(NSString *) fieldName FieldValue:(NSString*)fieldValue {
    
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];

    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:coreDataContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:fieldName, fieldValue]];
    
    NSError *error;
    NSArray *array = [coreDataContext executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in array) {
        [coreDataContext deleteObject:obj];
    }
    
    [coreDataContext save:&error];
}


- (void) login:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete {
    
    stc_request_count++;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"image/jpeg", nil];
    [manager POST:LOGIN_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
#if DEBUG
        NSLog(@"Autho: %@", responseObject);
#endif
        stc_request_count--;
        complete(responseObject ,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        stc_request_count--;
        NSLog(@"Error: %@", error);
        complete(nil ,error);
    }];
}

- (void) getFixtureOptions: (RequestCompletionHandler)complete
{
    stc_request_count++;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"image/jpeg", nil];
    [manager POST:GET_FIXTURE_OPTIONS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
#if DEBUG
        NSLog(@"Autho: %@", responseObject);
#endif
        stc_request_count--;
        complete(responseObject ,nil);
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:responseObject forKey:@"FIXTURE_OPTIONS"];
        [prefs synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        stc_request_count--;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *responseJSON = [prefs objectForKey:@"FIXTURE_OPTIONS"];
        if(responseJSON != nil) {
            complete(responseJSON, nil);
        }
        else
        {
            NSLog(@"Error: %@", error);
            complete(nil ,error);
        }
    }];
}

- (void) getStates:(RequestCompletionHandler)complete {
    
    stc_request_count++;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"image/jpeg", nil];
    [manager POST:GET_STATES_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
#if DEBUG
        NSLog(@"Autho: %@", responseObject);
#endif

        stc_request_count--;
        complete(responseObject ,nil);
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:responseObject forKey:@"STATES"];
        [prefs synchronize];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        stc_request_count--;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *responseJSON = [prefs objectForKey:@"STATES"];
        if(responseJSON != nil) {
            complete(responseJSON, nil);
        } else {
            NSLog(@"Error: %@", error);
            complete(nil ,error);
        }
    }];
}

- (BOOL) setObjectAsUnsync:(NSString*)type ObjId:(NSNumber*)objId
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    NSArray *results = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"type" IDValue:objId.stringValue];
    if(results != nil && [results count] > 0) return YES;
    
    OperationInfo *operationInfo = [NSEntityDescription insertNewObjectForEntityForName:@"OperationInfo" inManagedObjectContext:coreDataContext];
    
    operationInfo.type = type;
    operationInfo.obj_id = [NSNumber numberWithInt:objId.intValue];
    NSError *error;
    if(NO == [coreDataContext save:&error])
    {
        return  NO;
    }
    
    return YES;
}

- (BOOL) setObjectAsUnsync:(NSString*)type Value:(NSString*)value
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    NSArray *results = [APIService getObjectsFromCoreData:@"OperationInfo" IDName:@"value" StringValue:value];
    if(results != nil && [results count] > 0) return YES;
    
    OperationInfo *operationInfo = [NSEntityDescription insertNewObjectForEntityForName:@"OperationInfo" inManagedObjectContext:coreDataContext];
    
    operationInfo.type = type;
    operationInfo.value = value;
    NSError *error;
    if(NO == [coreDataContext save:&error])
    {
        return  NO;
    }
    
    return YES;
}

// API for communication with server
- (void) request2Server:(NSString*)apiUrl Params:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    stc_request_count++;
    // send request to server
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"image/jpeg", nil];
    [manager POST:apiUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#if DEBUG
        NSLog(@"Autho: %@", responseObject);
#endif
        stc_request_count--;
        complete(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        stc_request_count--;
        NSLog(@"Error: %@", error);
        complete(nil, error);
    }];
}

- (void) getTimeZoneDiff:(RequestCompletionHandler)complete
{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSString *tzName = [timeZone abbreviation];
    NSDictionary *params = @{@"timeZone":tzName};
    [self request2Server:GET_TIMEZONE_DIFF Params:params onCompletion:complete];
}

// for survey
- (void) getSurveysFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_SURVEYLIST_URL Params:params onCompletion:complete];
}

- (void) getSurveyTreeFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_SURVEY_TREE Params:params onCompletion:complete];
}

- (void) addSurvey2Server:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_SURVEYID_URL Params:params onCompletion:complete];
}

- (void) saveSurvey2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:EDIT_SURVEY_URL Params:params onCompletion:complete];
}

- (void) deleteSurveyFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete {
    [self request2Server:DELETE_SURVEY_URL Params:params onCompletion:complete];
}

// floor
- (void) getFloorsFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_FLOORLIST_URL Params:params onCompletion:complete];
}

- (void) addFloor2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_FLOORID_URL Params:params onCompletion:complete];
}

- (void) saveFloor2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:EDIT_FLOOR_URL Params:params onCompletion:complete];
}

- (void) copyFloor2Server:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:COPY_FLOOR_URL Params:params onCompletion:complete];
}

- (void) deleteFloorFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete {
    [self request2Server:DELETE_FLOOR_URL Params:params onCompletion:complete];
}

// area
- (void) getAreasFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_AREALIST_URL Params:params onCompletion:complete];
}

- (void) addArea2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_AREAID_URL Params:params onCompletion:complete];
}

- (void) saveArea2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:EDIT_AREA_URL Params:params onCompletion:complete];
}

- (void) copyArea2Server:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:COPY_AREA_URL Params:params onCompletion:complete];
}

- (void) deleteAreaFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete {
    [self request2Server:DELETE_AREA_URL Params:params onCompletion:complete];
}

// fixture
- (void) getFixturesFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_FIXTURELIST_URL Params:params onCompletion:complete];
}

- (void) addFixture2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:GET_FIXTUREID_URL Params:params onCompletion:complete];
}

- (void) saveFixture2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:EDIT_FIXTURE_URL Params:params onCompletion:complete];
}

- (void) deleteFixtureFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete {
    [self request2Server:DELETE_FIXTURE_URL Params:params onCompletion:complete];
}

- (void) getConversionList: (RequestCompletionHandler)complete
{
    [self request2Server:GET_CONVERSIONS_URL Params:nil onCompletion:(RequestCompletionHandler)complete];
}

- (void) getRetrofits:(RequestCompletionHandler)complete
{
    [self request2Server:GET_RETROFITS_URL Params:nil onCompletion:(RequestCompletionHandler)complete];
}

// change sequences
- (void) changeSequence2ServerForObject:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete
{
    [self request2Server:CHANGE_SEQUENCE_URL Params:params onCompletion:complete];
}

@end

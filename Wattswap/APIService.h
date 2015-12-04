//
//  APIService.h
//  Wattswap
//
//  Created by User on 5/13/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIService : NSObject
//{
//    int stc_request_count;
//}

+ (id)sharedManager;
+ (BOOL)isCompleted;
+ (NSArray*) getObjectsFromCoreData:(NSString*)entityName IDName:(NSString*)idName IDValue:(NSString*)idVal;
+ (NSArray*) getObjectsFromCoreData:(NSString*)entityName IDName:(NSString*)idName StringValue:(NSString*)idVal;
+ (NSArray*) getObjectsFromCoreData:(NSString*)entityName;
+ (NSArray*) getObjectsFromCoreData:(NSString *)entityName Where:(NSString*)where;

+ (BOOL) updateWithCondition:(NSString*)entityName Where:(NSString*)where Data:(NSDictionary*)data;
+ (void) deleteObjectFromCoreData:(NSString*)entityName Condition:(NSString *) fieldName FieldValue:(NSString*)fieldValue;


typedef void(^RequestCompletionHandler)(NSDictionary *result, NSError *error);

- (void) login:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;

- (void) getFixtureOptions: (RequestCompletionHandler)complete;
- (void) getStates: (RequestCompletionHandler)complete;

- (void) getTimeZoneDiff:(RequestCompletionHandler)complete;

// survey
- (void) getSurveyTreeFromServer:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete;
- (void) getSurveysFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;
- (void) getFloorsFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;
- (void) getAreasFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;
- (void) getFixturesFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;

// delete api
- (void) deleteSurveyFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;
- (void) deleteAreaFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;
- (void) deleteFixtureFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;
- (void) deleteFloorFromServer:(NSDictionary *) params onCompletion:(RequestCompletionHandler) complete;

// change sequence
- (void) changeSequence2ServerForObject:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;

// save unsynced operation
- (BOOL) setObjectAsUnsync:(NSString*)type ObjId:(NSNumber*)objId;
- (BOOL) setObjectAsUnsync:(NSString*)type Value:(NSString*)value;

- (void) addSurvey2Server:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete;
- (void) saveSurvey2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;

// floor
- (void) addFloor2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;
- (void) saveFloor2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;
- (void) copyFloor2Server:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete;

// area
- (void) addArea2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;
- (void) saveArea2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;
- (void) copyArea2Server:(NSDictionary *)params onCompletion:(RequestCompletionHandler)complete;

// fixture
- (void) addFixture2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;
- (void) saveFixture2Server:(NSDictionary*)params onCompletion:(RequestCompletionHandler)complete;

// conversion list
- (void) getConversionList: (RequestCompletionHandler)complete;
- (void) getRetrofits:(RequestCompletionHandler)complete;

@end

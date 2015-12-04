//
//  SurveyInfo.h
//  Wattswap
//
//  Created by MY on 8/27/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SurveyInfo : NSManagedObject

@property (nonatomic, retain) NSString * accountnumber;
@property (nonatomic, retain) NSString * addressline1;
@property (nonatomic, retain) NSString * addressline2;
@property (nonatomic, retain) NSString * breff;
@property (nonatomic, retain) NSString * btototalfutage;
@property (nonatomic, retain) NSString * btype;
@property (nonatomic, retain) NSString * bunit;
@property (nonatomic, retain) NSString * butilitycompany;
@property (nonatomic, retain) NSString * cemail;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * cname;
@property (nonatomic, retain) NSString * cphone;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * ofp_path;
@property (nonatomic, retain) NSNumber * ofp_sid;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * rateperwatt;
@property (nonatomic, retain) NSDate * scheduled;
@property (nonatomic, retain) NSNumber * sid;
@property (nonatomic, retain) NSString * sname;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * supervisor_id;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSDate * stime;

- (void) initWithDict:(NSDictionary*)dic;

@end

//
//  FixtureInfo.h
//  Wattswap
//
//  Created by MY on 9/13/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FixtureInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * aid;
@property (nonatomic, retain) NSString * hoursperweek;
@property (nonatomic, retain) NSString * hoursinyear;
@property (nonatomic, retain) NSString * ballastfactor;
@property (nonatomic, retain) NSString * ballasttype;
@property (nonatomic, retain) NSString * bulbsperfixture;
@property (nonatomic, retain) NSString * lampcode;
@property (nonatomic, retain) NSString * control;
@property (nonatomic, retain) NSNumber * fid;
@property (nonatomic, retain) NSString * fixturecnt;
@property (nonatomic, retain) NSNumber * fixtureid;
@property (nonatomic, retain) NSString * fixturetype;
@property (nonatomic, retain) NSString * hoursperday;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * mounting;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * ofp_aid;
@property (nonatomic, retain) NSNumber * ofp_fid;
@property (nonatomic, retain) NSNumber * ofp_fixtureid;
@property (nonatomic, retain) NSString * ofp_path;
@property (nonatomic, retain) NSNumber * ofp_sid;
@property (nonatomic, retain) NSString * option;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * replacement_id;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * sid;
@property (nonatomic, retain) NSDate * stime;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * supervisor_id;
@property (nonatomic, retain) NSString * daysperweek;
@property (nonatomic, retain) NSString * wattsperbulb;
@property (nonatomic, retain) NSString * lense;
@property (nonatomic, retain) NSString * lamp;
@property (nonatomic, retain) NSString * fixturesize;
@property (nonatomic, retain) NSString * lamptype;
@property (nonatomic, retain) NSString * realwatts;

- (void)initWithDict:(NSDictionary*)dic;

@end

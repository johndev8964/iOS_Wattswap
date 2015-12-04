//
//  FixtureInfo.m
//  Wattswap
//
//  Created by MY on 9/13/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "FixtureInfo.h"


@implementation FixtureInfo

@dynamic aid;
@dynamic hoursperweek;
@dynamic hoursinyear;
@dynamic ballastfactor;
@dynamic ballasttype;
@dynamic bulbsperfixture;
@dynamic lampcode;
@dynamic control;
@dynamic fid;
@dynamic fixturecnt;
@dynamic fixtureid;
@dynamic fixturetype;
@dynamic hoursperday;
@dynamic height;
@dynamic mounting;
@dynamic note;
@dynamic ofp_aid;
@dynamic ofp_fid;
@dynamic ofp_fixtureid;
@dynamic ofp_path;
@dynamic ofp_sid;
@dynamic option;
@dynamic path;
@dynamic replacement_id;
@dynamic seq;
@dynamic sid;
@dynamic stime;
@dynamic style;
@dynamic supervisor_id;
@dynamic daysperweek;
@dynamic wattsperbulb;
@dynamic lense;
@dynamic lamp;
@dynamic fixturesize;
@dynamic lamptype;
@dynamic realwatts;

- (void)initWithDict:(NSDictionary*)dic {
    
    Global *global = [Global sharedManager];
    self.sid = NFS([dic objectForKey:@"survey_id"]);
    self.fid = NFS([dic objectForKey:@"floor_id"]);
    self.aid = NFS([dic objectForKey:@"area_id"]);
    
    self.fixtureid = NFS([dic objectForKey:@"fixture_id"]);
    self.fixturetype = [dic objectForKey:@"fixture_type"];
    self.fixturecnt = [dic objectForKey:@"count"];
    self.lampcode = [dic objectForKey:@"lamp_code"];
    self.style = [dic objectForKey:@"style"];
    self.mounting = [dic objectForKey:@"mounting"];
    self.option = [dic objectForKey:@"option"];
    self.control = [dic objectForKey:@"controlled"];
    self.height = [dic objectForKey:@"height"];
    self.note = [dic objectForKey:@"notes"];
    self.hoursperday = [dic objectForKey:@"hrs_per_day"];
    self.daysperweek = [dic objectForKey:@"days_per_week"];
    self.hoursperweek = [NSString stringWithFormat:@"%d", [self.hoursperday intValue] * [self.daysperweek intValue]];
    self.bulbsperfixture = [dic objectForKey:@"bulbs_per_fixture"];
    self.wattsperbulb = [dic objectForKey:@"watts_per_bulb"];
    self.hoursinyear = [NSString stringWithFormat:@"%d", [self.hoursperday intValue] * [self.daysperweek intValue] * 52];
    self.ballasttype = [dic objectForKey:@"ballast"];
    self.ballastfactor = [dic objectForKey:@"factor"];
    self.seq = NFS([dic objectForKey:@"seq"]);
    
    self.lense = [dic objectForKey:@"lense"];
    self.lamp = [dic objectForKey:@"lamp"];
    self.fixturesize = [dic objectForKey:@"fixture_size"];
    self.lamptype = [dic objectForKey:@"lamp_type"];
    self.realwatts = [dic objectForKey:@"lamp_real_wattage"];
    
    if (ISNull([dic objectForKey:@"fixture_image"])) {
        self.path = @"";
    }
    else {
        self.path = [dic objectForKey:@"fixture_image"];
    }
    
    self.replacement_id = NFS([dic objectForKey:@"replacement_id"]);
    NSString *lastModified = [dic objectForKey:@"create_ts"];
    self.stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
}

@end

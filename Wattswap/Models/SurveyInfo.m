//
//  SurveyInfo.m
//  Wattswap
//
//  Created by MY on 8/27/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "SurveyInfo.h"


@implementation SurveyInfo

@dynamic accountnumber;
@dynamic addressline1;
@dynamic addressline2;
@dynamic breff;
@dynamic btototalfutage;
@dynamic btype;
@dynamic bunit;
@dynamic butilitycompany;
@dynamic cemail;
@dynamic city;
@dynamic cname;
@dynamic cphone;
@dynamic note;
@dynamic ofp_path;
@dynamic ofp_sid;
@dynamic path;
@dynamic rateperwatt;
@dynamic scheduled;
@dynamic sid;
@dynamic sname;
@dynamic state;
@dynamic status;
@dynamic street;
@dynamic supervisor_id;
@dynamic zip;
@dynamic stime;


- (void) initWithDict:(NSDictionary *)dic {
    
    Global *global = [Global sharedManager];
    self.supervisor_id = [dic objectForKey:@"supervisor_id"];
    self.sid = NFS([dic objectForKey:@"survey_id"]);

    self.sname = [dic objectForKey:@"survey_facility_name"];
    self.addressline1 = [dic objectForKey:@"survey_facility_add_l1"];
    self.addressline2 = [dic objectForKey:@"survey_facility_add_l2"];
    self.city = [dic objectForKey:@"survey_facility_city"];
    self.state = [dic objectForKey:@"state_id"];
    self.zip = [dic objectForKey:@"survey_facility_zip"];
    self.cname = [dic objectForKey:@"survey_contact_name"];
    self.cphone = [dic objectForKey:@"survey_contact_phone"];
    self.cemail = [dic objectForKey:@"survey_contact_email"];
    
    NSString* scheduled = [dic objectForKey:@"survey_schedule_date"];
    self.scheduled = [global getDateFromString:scheduled Format:@"yyyy-MM-dd HH:mm:ss"];
    self.note = [dic objectForKey:@"survey_note"];
    self.bunit = [dic objectForKey:@"survey_building_units"];
    self.btype = [dic objectForKey:@"survey_building_type"];
    self.breff = [dic objectForKey:@"survey_reffered_by"];
    self.btototalfutage = [dic objectForKey:@"survey_sq_foot"];
    self.butilitycompany = [dic objectForKey:@"survey_utility_company"];
    self.accountnumber = [dic objectForKey:@"survey_account_no"];
    self.rateperwatt = [dic objectForKey:@"survey_rate_per_watt"];
    
    NSString *last_modified = [dic objectForKey:@"last_modified"];
    self.stime = [global getDateFromString:last_modified Format:@"yyyy-MM-dd HH:mm:ss"];
    if (ISNull([dic objectForKey:@"survey_image_path"])) {
        self.path = @"";
    }
    else {
        self.path = [dic objectForKey:@"survey_image_path"];
    }
}

@end

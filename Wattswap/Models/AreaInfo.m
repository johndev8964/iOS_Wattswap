//
//  AreaInfo.m
//  Wattswap
//
//  Created by MY on 8/27/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "AreaInfo.h"


@implementation AreaInfo

@dynamic adesc;
@dynamic aid;
@dynamic fid;
@dynamic ofp_aid;
@dynamic ofp_fid;
@dynamic ofp_sid;
@dynamic sid;
@dynamic stime;
@dynamic seq;

- (void) initWithDict:(NSDictionary *)dic {
    
    Global *global = [Global sharedManager];
    self.sid = NFS([dic objectForKey:@"survey_id"]);
    self.fid = NFS([dic objectForKey:@"floor_id"]);
    self.aid = NFS([dic objectForKey:@"area_id"]);
    self.adesc = [dic objectForKey:@"area_name"];
    self.seq = NFS([dic objectForKey:@"seq"]);
    NSString *lastModified = [dic objectForKey:@"last_modified"];
    self.stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
}

@end

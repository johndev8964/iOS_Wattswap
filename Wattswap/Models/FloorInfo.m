//
//  FloorInfo.m
//  Wattswap
//
//  Created by MY on 8/27/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "FloorInfo.h"


@implementation FloorInfo

@dynamic fdesc;
@dynamic fid;
@dynamic ofp_fid;
@dynamic ofp_sid;
@dynamic sid;
@dynamic stime;
@dynamic seq;

- (void) initWithDict:(NSDictionary *)dic {
    
    Global *global = [Global sharedManager];
    self.sid = NFS([dic objectForKey:@"survey_id"]);
    self.fid = NFS([dic objectForKey:@"floor_id"]);
    self.fdesc = [dic objectForKey:@"floor_name"];
    self.seq = NFS([dic objectForKey:@"seq"]);
    NSString *lastModified = [dic objectForKey:@"last_modified"];
    self.stime = [global getDateFromString:lastModified Format:@"yyyy-MM-dd HH:mm:ss"];
}

@end

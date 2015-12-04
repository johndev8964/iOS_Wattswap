//
//  RetrofitInfo.m
//  Wattswap
//
//  Created by MY on 9/14/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "RetrofitInfo.h"


@implementation RetrofitInfo

@dynamic retrofit_id;
@dynamic retrofit_old_fixture_type;
@dynamic retrofit_old_lamp;
@dynamic retrofit_description;
@dynamic retrofit_lamp;
@dynamic retrofit_ballast;
@dynamic retrofit_image;
@dynamic retrofit_real_lamp_wattage;

- (void)initWithDict:(NSDictionary*)dic {
    
    self.retrofit_id = NFS([dic objectForKey:@"retrofit_id"]);
    self.retrofit_old_fixture_type = [dic objectForKey:@"retrofit_old_fixture_type"];
    self.retrofit_old_lamp = [dic objectForKey:@"retrofit_old_lamp"];
    self.retrofit_description = [dic objectForKey:@"retrofit_description"];
    self.retrofit_lamp = [dic objectForKey:@"retrofit_lamp"];
    self.retrofit_ballast = [dic objectForKey:@"retrofit_ballast"];
    self.retrofit_real_lamp_wattage = [dic objectForKey:@"retrofit_real_lamp_wattage"];
    self.retrofit_image = [dic objectForKey:@"retrofit_image"];
}
@end

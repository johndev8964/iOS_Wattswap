//
//  RetrofitInfo.h
//  Wattswap
//
//  Created by MY on 9/14/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RetrofitInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * retrofit_id;
@property (nonatomic, retain) NSString * retrofit_old_fixture_type;
@property (nonatomic, retain) NSString * retrofit_old_lamp;
@property (nonatomic, retain) NSString * retrofit_description;
@property (nonatomic, retain) NSString * retrofit_lamp;
@property (nonatomic, retain) NSString * retrofit_ballast;
@property (nonatomic, retain) NSString * retrofit_image;
@property (nonatomic, retain) NSString * retrofit_real_lamp_wattage;

- (void)initWithDict:(NSDictionary*)dic;

@end

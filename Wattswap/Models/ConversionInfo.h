//
//  ConversionInfo.h
//  Wattswap
//
//  Created by MY on 8/28/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ConversionInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * conversion_id;
@property (nonatomic, retain) NSString * fixture_code;
@property (nonatomic, retain) NSNumber * fixture_input_watt;
@property (nonatomic, retain) NSString * fixture_name;
@property (nonatomic, retain) NSString * fixture_type;
@property (nonatomic, retain) NSString * image_path;
@property (nonatomic, retain) NSString * lamp_ballast_type;
@property (nonatomic, retain) NSString * retrofit_desc;

@end

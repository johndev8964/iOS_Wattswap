//
//  FloorInfo.h
//  Wattswap
//
//  Created by MY on 8/27/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FloorInfo : NSManagedObject

@property (nonatomic, retain) NSString * fdesc;
@property (nonatomic, retain) NSNumber * fid;
@property (nonatomic, retain) NSNumber * ofp_fid;
@property (nonatomic, retain) NSNumber * ofp_sid;
@property (nonatomic, retain) NSNumber * sid;
@property (nonatomic, retain) NSDate * stime;
@property (nonatomic, retain) NSNumber * seq;

-(void) initWithDict:(NSDictionary*)dic;

@end

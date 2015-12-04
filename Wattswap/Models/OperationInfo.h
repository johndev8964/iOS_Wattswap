//
//  OperationInfo.h
//  Wattswap
//
//  Created by MY on 8/27/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OperationInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * obj_id;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;

@end

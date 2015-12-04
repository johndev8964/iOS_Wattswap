//
//  FloorTableViewCell.h
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloorTableViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *floorName;
@property (weak, nonatomic) IBOutlet UILabel *numOfAreas;
@property (weak, nonatomic) IBOutlet UILabel *numOfFixtures;

@property (nonatomic, retain) FloorInfo *floor;
@property (nonatomic, retain) NSString *floorId;
@property (nonatomic) int index;

@end

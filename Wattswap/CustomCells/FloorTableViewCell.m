//
//  FloorTableViewCell.m
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "FloorTableViewCell.h"
#import "CoredataManager.h"
#import "APIService.h"

@implementation FloorTableViewCell

@synthesize floorName, numOfAreas, numOfFixtures, index, floor;

- (void)awakeFromNib {
    // Initialization code
    
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

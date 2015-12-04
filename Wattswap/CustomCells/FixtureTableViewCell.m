//
//  FixtureTableViewCell.m
//  Wattswap
//
//  Created by User on 5/24/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "FixtureTableViewCell.h"
#import "CoredataManager.h"
#import "APIService.h"

@implementation FixtureTableViewCell

@synthesize fixtureCnts, fixtureTypeName;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

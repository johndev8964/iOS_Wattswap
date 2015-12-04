//
//  SurveyTableViewCell.m
//  Wattswap
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "SurveyTableViewCell.h"

@implementation SurveyTableViewCell

@synthesize surveyName, surveyDesc, surveyScheduled;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

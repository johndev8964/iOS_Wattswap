//
//  SurveyTableViewCell.h
//  Wattswap
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SurveyTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *surveyName;
@property (nonatomic, retain) IBOutlet UILabel *surveyDesc;
@property (nonatomic, retain) IBOutlet UILabel *surveyScheduled;

@end

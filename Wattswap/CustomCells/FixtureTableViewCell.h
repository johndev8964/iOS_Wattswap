//
//  FixtureTableViewCell.h
//  Wattswap
//
//  Created by User on 5/24/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FixtureTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fixtureTypeName;
@property (weak, nonatomic) IBOutlet UILabel *fixtureCnts;
@property (weak, nonatomic) IBOutlet UILabel *fixtureLampCodeAndMountingType;
@property (weak, nonatomic) IBOutlet UIImageView *fixtureImage;


@property (nonatomic, retain) UIAlertView* fixtureDeleteAlertView;
@property (nonatomic) int index;

@end

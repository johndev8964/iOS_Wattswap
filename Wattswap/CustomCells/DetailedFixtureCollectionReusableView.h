//
//  DetailedFixtureCollectionReusableView.h
//  Wattswap
//
//  Created by MY on 8/22/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedFixtureCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UILabel *lblFixtureCnt;
@property (strong, nonatomic) IBOutlet UILabel *lblFixtureWatts;
@property (strong, nonatomic) IBOutlet UILabel *lblFixtureHours;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalCost;

@property (strong, nonatomic) IBOutlet UILabel *lblFixtureCntC;
@property (strong, nonatomic) IBOutlet UILabel *lblFixtureWattsC;
@property (strong, nonatomic) IBOutlet UILabel *lblFixtureHoursC;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalCostC;

@property (strong, nonatomic) IBOutlet UILabel *lblTotalSaving;
@property (strong, nonatomic) IBOutlet UILabel *lblTutorial;

@property (strong, nonatomic) IBOutlet UILabel *lblFixtureStyleName;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@end

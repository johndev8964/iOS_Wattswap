//
//  DetailedFixtureViewController.h
//  Wattswap
//
//  Created by User on 5/26/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailedFixtureCollectionReusableView.h"

@protocol DetailedFixtureViewControllerDelegate <NSObject>

- (void)didChangedReplacement:(int)replacement_id;

@end

@interface DetailedFixtureViewController : UIViewController <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain, nonatomic) id<DetailedFixtureViewControllerDelegate> delegate;

@property (nonatomic, retain) NSString *fixtureTypeStyleNameText;
@property (nonatomic, retain) NSString *fixtureCntText;
@property (nonatomic, retain) NSString *fixtureWattsText;
@property (nonatomic, retain) NSString *hoursPerWeekText;
//@property (nonatomic, retain) NSString *fixtureBulbCntText;

@property (nonatomic, retain) NSString *fixtureType;
@property (nonatomic, retain) NSString *fixtureLamp;
@property (nonatomic, retain) NSArray *aryConversions;

@property (nonatomic, retain) RetrofitInfo *conversionInfo;
@property (nonatomic, readwrite) int replacement_id;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewConversionCandiates;


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

- (IBAction) goBack:(id)sender;

@end

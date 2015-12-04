//
//  AreaTableViewCell.h
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaTableViewCell : SWTableViewCell <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *areaName;
@property (weak, nonatomic) IBOutlet UILabel *numOfFixtures;
@property (weak, nonatomic) IBOutlet UIView  *btnView;

@property (nonatomic) int index;
@property (nonatomic, retain) AreaInfo* area;
@property (nonatomic, retain) UIAlertView* areaCopyAlertView;
@property (nonatomic, retain) UIAlertView* areaDeleteAlertView;

- (void) addGesture;
- (void) btnViewSwipeRight;


- (IBAction) copyArea:(id)sender;
- (IBAction) editArea:(id)sender;
- (IBAction) deleteArea:(id)sender;

@end

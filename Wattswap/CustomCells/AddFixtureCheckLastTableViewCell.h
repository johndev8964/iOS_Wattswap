//
//  AddFixtureCheckLastTableViewCell.h
//  Wattswap
//
//  Created by MY on 8/5/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFixtureViewController.h"

@interface AddFixtureCheckLastTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *otherOption;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;

@property (retain, nonatomic) NewFixtureViewController *fixtureListCtrl;
@property (readwrite, nonatomic) NSInteger              m_nTableType;
- (void) setCheckStatus:(BOOL) status;
@end

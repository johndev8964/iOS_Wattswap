//
//  AddFixtureCheckTableViewCell.h
//  Wattswap
//
//  Created by User on 5/25/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFixtureViewController.h"

@class AddFixtureCheckTableViewCell;

@protocol AddFixtureCheckTableViewCellDelegate <NSObject>

@optional
- (void) didCheckedItem:(AddFixtureCheckTableViewCell* )sender;

@end

@interface AddFixtureCheckTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *fixtureTypeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *checkImageView;

@property (nonatomic, retain) NewFixtureViewController *addFixtureCtrl;
@property (assign) id<AddFixtureCheckTableViewCellDelegate> delegate;

- (IBAction) itemCheck:(id)sender;
- (void) setCheckStatus:(BOOL) status;
@end

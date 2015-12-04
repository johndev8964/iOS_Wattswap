//
//  OptionTableFormView.h
//  Wattswap
//
//  Created by MY on 8/18/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionTableFormViewDelegate <NSObject>

@optional
- (void)didSelectedOptions:(NSArray*)options OptionTableView:(UIView*)view;
- (void)didSelectedOption:(NSString*)option OptionTableView:(UIView*)view;

@end

@interface OptionTableFormView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SWTableViewCellDelegate>

@property (retain, nonatomic) id<OptionTableFormViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *m_tblOptions;
@property (strong, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (strong, nonatomic)          UILabel  *m_lblBudy;
@property (nonatomic, readwrite)       BOOL     m_bEnableEmptyItem;
@property (nonatomic, readwrite)       CGFloat  m_fltCellHeight;

- (void)setEnableMultipleSelection:(BOOL)enable;
- (void)showOptionTable:(UIView*)parent Title:(NSString*)title Options:(NSArray*)options SelectedOptions:(NSArray*)selectedOptions;
- (void)showOptionTable:(UIView*)parent Title:(NSString*)title Options:(NSArray*)options Others:(NSArray*)others SelectedOptions:(NSArray*)selectedOptions;

@end

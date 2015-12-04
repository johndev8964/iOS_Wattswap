//
//  OptionTableViewCell.h
//  Wattswap
//
//  Created by MY on 8/18/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionTableViewCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet M13Checkbox *m_chkState;
@property (strong, nonatomic) IBOutlet UILabel *m_lblOptionName;
@property (strong, nonatomic) IBOutlet UITextField *m_textEditBox;
@property (strong, nonatomic) IBOutlet UILabel *m_lblOthers;

- (void)setStateAsSelected:(BOOL)selected;
- (void) setCheckBoxEnabled:(BOOL)enabled;
- (void) setEditBoxEnabled:(BOOL)enabled;
- (BOOL) isSelected;
- (NSString*)getSelectedValue;

@end

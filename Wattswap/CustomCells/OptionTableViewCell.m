//
//  OptionTableViewCell.m
//  Wattswap
//
//  Created by MY on 8/18/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "OptionTableViewCell.h"

@implementation OptionTableViewCell
{
    BOOL m_checkboxEnabled;
    BOOL m_selected;
}

- (void)awakeFromNib {
    // Initialization code
    m_checkboxEnabled = NO;
    m_selected = NO;
}

- (void)setStateAsSelected:(BOOL)selected {

    m_selected = selected;
    if(m_checkboxEnabled)
        [self.m_chkState setCheckState:(m_selected ? M13CheckboxStateChecked : M13CheckboxStateUnchecked)];
    else
    {
        if(m_selected)
            self.backgroundColor = UIColorFromRGBValue(0xcccccc);
        else
            self.backgroundColor = [UIColor clearColor];
    };
}

- (void) setEditBoxEnabled:(BOOL)enabled {
//    [self.m_lblOptionName setHidden:enabled];
//    [self.m_textEditBox setHidden:!enabled];
}

- (void) setCheckBoxEnabled:(BOOL)enabled {
    m_checkboxEnabled = enabled;
    if(enabled)
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    [self.m_chkState setHidden:!enabled];
}

- (BOOL) isSelected {
    m_selected = ([self.m_chkState checkState] == M13CheckboxStateChecked);
    return m_selected;
}

- (NSString*)getSelectedValue {
    NSString *optionValue = self.m_lblOptionName.text;
    if(optionValue == nil || optionValue.length == 0) {
        optionValue = self.m_textEditBox.text;
        if(optionValue == nil || optionValue.length == 0)
            optionValue = @"Other";
    }
    return optionValue;
}

@end

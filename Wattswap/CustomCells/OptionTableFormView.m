//
//  OptionTableFormView.m
//  Wattswap
//
//  Created by MY on 8/18/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "OptionTableFormView.h"
#import "OptionTableViewCell.h"

@implementation OptionTableFormView
{
    BOOL m_bIsMutiSelectionEnabled;
    NSArray *m_aryOptions;
    NSArray *m_aryOthers;
    NSMutableArray *m_arySelectedOptions;
    
    NSString *strOtherOption;
    BOOL isEnd;
}

@synthesize m_lblTitle, m_tblOptions, m_fltCellHeight;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    // Initialization code
    m_bIsMutiSelectionEnabled = NO;
    m_aryOptions = nil;
    m_aryOthers = nil;
    m_arySelectedOptions = nil;
    m_tblOptions.delegate = self;
    m_tblOptions.dataSource = self;
    isEnd = NO;
    m_fltCellHeight = 44.0f;
}

- (IBAction)onClickBtnOK:(id)sender {
    
    if(m_bIsMutiSelectionEnabled) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedOptions:OptionTableView:)]) {
            NSArray *arySelectedOptions = [self getSelectedOptions];
            if([arySelectedOptions count] == 0)
            {
                if(self.m_bEnableEmptyItem == NO)
                {
                    [self makeToast:@"Please select a item."];
                    return;
                }
                else
                {
                    if(self.m_lblBudy != nil) {
                        self.m_lblBudy.textColor = UIColorFromRGBValue(0xcccccc);
                        [self.m_lblBudy setText:@"Please select..."];
                    }
                }
            }
            else
            {
                if(self.m_lblBudy != nil) {
                    NSString *strOptions = [arySelectedOptions objectAtIndex:0];
                    for(int i=1; i<[arySelectedOptions count]; i++) {
                        strOptions = [strOptions stringByAppendingString:@","];
                        strOptions = [strOptions stringByAppendingString:[arySelectedOptions objectAtIndex:i]];
                    }
                    self.m_lblBudy.textColor = UIColorFromRGBValue(0x000000);
                    [self.m_lblBudy setText:strOptions];
                }
            }
            [self.delegate didSelectedOptions:arySelectedOptions OptionTableView:self];
        }
    } else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedOption:OptionTableView:)]) {
            NSArray *arySelectedOptions = [self getSelectedOptions];
            if([arySelectedOptions count] == 0) {
                if(self.m_bEnableEmptyItem == NO)
                {
                    [self makeToast:@"Please select a item."];
                    return;
                }
                else
                {
                    if(self.m_lblBudy != nil) {
                        self.m_lblBudy.textColor = UIColorFromRGBValue(0xcccccc);
                        [self.m_lblBudy setText:@"Please select..."];
                    }
                }
                
                [self.delegate didSelectedOption:nil OptionTableView:self];
            }
            else {
                if(self.m_lblBudy != nil) {
                    self.m_lblBudy.textColor = UIColorFromRGBValue(0x000000);
                    [self.m_lblBudy setText:[arySelectedOptions objectAtIndex:0]];
                }
                
                [self.delegate didSelectedOption:[arySelectedOptions objectAtIndex:0] OptionTableView:self];
            }
        }
    }
    [self removeFromSuperview];
}

- (IBAction)onClickBtnCancel:(id)sender {
    [self removeFromSuperview];
}

- (void)setEnableMultipleSelection:(BOOL)enable {
    m_bIsMutiSelectionEnabled = enable;
    [m_tblOptions setAllowsMultipleSelection:NO];
}

- (void)showOptionTable:(UIView*)parent Title:(NSString*)title Options:(NSArray*)options SelectedOptions:(NSArray*)selectedOptions {
    [self showOptionTable:parent Title:title Options:options Others:nil SelectedOptions:selectedOptions];
}

- (void)showOptionTable:(UIView*)parent Title:(NSString*)title Options:(NSArray*)options Others:(NSArray*)others SelectedOptions:(NSArray*)selectedOptions {
    
    m_aryOthers = others;
    if(m_aryOthers != nil)
        m_fltCellHeight = 100.0f;
    
    if([selectedOptions count] == 1) {
        NSString *firstOption = [selectedOptions objectAtIndex:0];
        if([firstOption isEqualToString:@"Please select..."])
            selectedOptions = @[];
    }
    
    m_lblTitle.text = title;
    m_aryOptions = options;
    m_arySelectedOptions = [[NSMutableArray alloc] init];
    [m_arySelectedOptions addObjectsFromArray:selectedOptions];
    
    [parent addSubview:self];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    for(int i=0; i<[m_arySelectedOptions count]; i++) {
        NSString *optionValue = [m_arySelectedOptions objectAtIndex:i];
        NSUInteger si = [m_aryOptions indexOfObject:optionValue];
        if(si == NSNotFound) {
            strOtherOption = optionValue;
            [m_tblOptions selectRowAtIndexPath:[NSIndexPath indexPathForRow:[m_aryOptions count] inSection:0]
                                      animated:NO
                                scrollPosition:UITableViewScrollPositionTop];
            continue;
        }
        else{
            [m_tblOptions selectRowAtIndexPath:[NSIndexPath indexPathForRow:si inSection:0]
                                      animated:NO
                                scrollPosition:UITableViewScrollPositionTop];
        }
    }

//    [m_tblOptions reloadData];
}

- (NSArray*) getSelectedOptions {
    
    NSMutableArray *arySelectedOptions = [[NSMutableArray alloc] init];
    if(m_bIsMutiSelectionEnabled == NO) {
        NSIndexPath *index = [m_tblOptions indexPathForSelectedRow];
        if(index.row < [m_aryOptions count]) {
            [arySelectedOptions addObject:[m_aryOptions objectAtIndex:index.row]];
        } else {
            OptionTableViewCell *cell = (OptionTableViewCell*)[m_tblOptions cellForRowAtIndexPath:index];
            [arySelectedOptions addObject:[cell getSelectedValue]];
        }
    } else {
        for(int i=0; i<[m_aryOptions count]; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
            OptionTableViewCell *cell = (OptionTableViewCell*)[m_tblOptions cellForRowAtIndexPath:index];
            if(cell.isSelected)
                [arySelectedOptions addObject:[m_aryOptions objectAtIndex:i]];
        }

        NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:[m_aryOptions count] inSection:0];
        OptionTableViewCell *cell = (OptionTableViewCell*)[m_tblOptions cellForRowAtIndexPath:lastIndex];
        if(cell.isSelected)
            [arySelectedOptions addObject:[cell getSelectedValue]];
    }
    return arySelectedOptions;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ([m_aryOptions count] + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OptionTableViewCell *optionCell = [[[NSBundle mainBundle] loadNibNamed:@"OptionTableViewCell" owner:nil options:nil] objectAtIndex:0];

    [optionCell setCheckBoxEnabled:m_bIsMutiSelectionEnabled];
    optionCell.m_textEditBox.delegate = self;
    if([m_aryOptions count] == indexPath.row) {
        [optionCell setEditBoxEnabled:YES];
        if(strOtherOption != nil && strOtherOption.length > 0) {
            NSUInteger si = [m_arySelectedOptions indexOfObject:strOtherOption];
            [optionCell setStateAsSelected:(si != NSNotFound)];
        }
        
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"11b5e2"] title:@"Clear"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"cccccc"] title:@"Edit"];
        optionCell.rightUtilityButtons = rightUtilityButtons;
        optionCell.delegate = self;
        
        optionCell.m_textEditBox.text = strOtherOption;
    } else {
        NSString *optionValue = [m_aryOptions objectAtIndex:indexPath.row];
        optionCell.m_lblOptionName.text = optionValue;
        [optionCell.m_textEditBox setHidden:YES];
        [optionCell setEditBoxEnabled:NO];
        NSUInteger si = [m_arySelectedOptions indexOfObject:optionValue];
        [optionCell setStateAsSelected:(si != NSNotFound)];
        
        if(m_aryOthers != nil) {
            NSString *strOthers = [m_aryOthers objectAtIndex:indexPath.row];
            [optionCell.m_lblOthers setText:strOthers];
        }
    }
    
    CGRect rectFrame = optionCell.frame;
    rectFrame.size.height = m_fltCellHeight;
    [optionCell setFrame:rectFrame];

    return optionCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return m_fltCellHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(m_bIsMutiSelectionEnabled == NO) {
        OptionTableViewCell * cell = (OptionTableViewCell*)[m_tblOptions cellForRowAtIndexPath:indexPath];
        [cell setStateAsSelected:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
{
    if(m_bIsMutiSelectionEnabled == NO) {
        OptionTableViewCell * cell = (OptionTableViewCell*)[m_tblOptions cellForRowAtIndexPath:indexPath];
        [cell setStateAsSelected:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    strOtherOption = textField.text;
    
    OptionTableViewCell * cell = (OptionTableViewCell*)[m_tblOptions cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[m_aryOptions count] inSection:0]];
    [cell.m_lblOptionName setHidden:NO];
    [textField setHidden:NO];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    strOtherOption = textField.text;
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    [cell hideUtilityButtonsAnimated:YES];
    
    OptionTableViewCell *optionCell = (OptionTableViewCell*)cell;
    [optionCell.m_lblOptionName setHidden:YES];
    if(index == 1) {
        [optionCell.m_textEditBox becomeFirstResponder];
    }
    else
    {
        OptionTableViewCell *optionCell = (OptionTableViewCell*)cell;
        optionCell.m_textEditBox.text = @"";
        [optionCell.m_textEditBox becomeFirstResponder];
    }
}

- (void)swipeableTableViewCellDidEndScrolling:(SWTableViewCell *)cell {
    isEnd = YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didScroll:(UIScrollView *)scrollView {
    
    if(isEnd) {
        CGPoint pt = scrollView.contentOffset;
        if(pt.x < 10) {
            pt.x = 0;
            [scrollView setContentOffset:pt];
            isEnd = NO;
        }
    }
}


@end

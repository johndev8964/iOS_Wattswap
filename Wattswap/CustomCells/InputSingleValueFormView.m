//
//  InputSingleValueFormView.m
//  Wattswap
//
//  Created by MY on 8/18/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "InputSingleValueFormView.h"


@implementation InputSingleValueFormView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    // Initialization code
    self.m_textValue.delegate = self;
}

- (void)showForm:(UIView*)parent
{
    [parent addSubview:self];
    NSLayoutConstraint *leadingConstraint =[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:parent
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:0];
    [parent addConstraint:leadingConstraint];
    
    NSLayoutConstraint *topConstraint =[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:parent
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:0];
    [parent addConstraint:topConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:[UIScreen mainScreen].bounds.size.height];
    [self addConstraint:heightConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:[UIScreen mainScreen].bounds.size.width];
    [self addConstraint:widthConstraint];
    
    CGRect originRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    originRect.origin.x = [UIScreen mainScreen].bounds.size.width;
    [self setFrame:originRect];
    
    [self updateConstraints];
    
    [UIView animateWithDuration:0.6 animations:^{
        CGRect originRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self setFrame: originRect];
    }];
}

- (IBAction)onClickBtnBack:(id)sender {
    [UIView animateWithDuration:0.6 animations:^{
        
        CGRect originRect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self setFrame: originRect];
    }];
    
    [NSTimer scheduledTimerWithTimeInterval: 0.7
                                                  target: self
                                                selector:@selector(onTick:)
                                                userInfo: nil repeats:NO];
}

-(void)onTick:(NSTimer *)timer {
    [self removeFromSuperview];
}

- (IBAction)onClickBtnSave:(id)sender {
    NSString *strValue = self.m_textValue.text;
    strValue = [strValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(strValue.length == 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didCanceled)])
            [self.delegate didCanceled];
        else
            [self makeToast:@"Please enter description."];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTakenValue:FromView:)]) {
        [self onClickBtnBack:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate didTakenValue:self.m_textValue.text FromView:self];
        });
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

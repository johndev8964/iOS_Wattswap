//
//  InputSingleValueFormView.h
//  Wattswap
//
//  Created by MY on 8/18/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputSingleValueInputFormViewDelegate <NSObject>

@required
- (void)didTakenValue:(NSString*)value FromView:(UIView*)view;

@optional
- (void)didCanceled;

@end

@interface InputSingleValueFormView : UIView<UITextFieldDelegate>

@property (retain, nonatomic) id<InputSingleValueInputFormViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (strong, nonatomic) IBOutlet UITextField *m_textValue;

- (void)showForm:(UIView*)parent;

@end

//
//  MainViewController.h
//  Wattswap
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *todayNumOfSurveys;
@property (weak, nonatomic) IBOutlet UIButton *dropBoxSigninBtn;
@property (weak, nonatomic) IBOutlet UIButton *dropBoxSignoutBtn;


@end

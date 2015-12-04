//
//  SettingsViewController.h
//  Wattswap
//
//  Created by MY on 9/3/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *m_lblUseVolume;
@property (strong, nonatomic) IBOutlet UILabel *m_lblPlaySound;
@property (strong, nonatomic) IBOutlet UILabel *m_lblUseVibration;
@property (strong, nonatomic) IBOutlet M13Checkbox *m_chkUseVolume;
@property (strong, nonatomic) IBOutlet M13Checkbox *m_chkPlaySound;
@property (strong, nonatomic) IBOutlet M13Checkbox *m_chkUseVibration;
@end

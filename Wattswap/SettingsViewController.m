//
//  SettingsViewController.m
//  Wattswap
//
//  Created by MY on 9/3/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize m_chkPlaySound, m_chkUseVibration, m_chkUseVolume;
@synthesize m_lblPlaySound, m_lblUseVibration, m_lblUseVolume;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTappedOnVolume)];
    tapGestureRecognizer1.numberOfTapsRequired = 1;
    [m_lblUseVolume addGestureRecognizer:tapGestureRecognizer1];
    m_lblUseVolume.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTappedOnSound)];
    tapGestureRecognizer2.numberOfTapsRequired = 1;
    [m_lblPlaySound addGestureRecognizer:tapGestureRecognizer2];
    m_lblPlaySound.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTappedOnVibration)];
    tapGestureRecognizer3.numberOfTapsRequired = 1;
    [m_lblUseVibration addGestureRecognizer:tapGestureRecognizer3];
    m_lblUseVibration.userInteractionEnabled = YES;
    
    
    Global *global = [Global sharedManager];
    if(global.bUseVolume) [m_chkUseVolume setCheckState:M13CheckboxStateChecked];
    if(global.bPlaySound) [m_chkPlaySound setCheckState:M13CheckboxStateChecked];
    if(global.bUseVibration) [m_chkUseVibration setCheckState:M13CheckboxStateChecked];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - label event hanlder
- (void)labelTappedOnVolume {
    M13CheckboxState state = [m_chkUseVolume checkState];
    [m_chkUseVolume setCheckState:(state == M13CheckboxStateChecked ? M13CheckboxStateUnchecked : M13CheckboxStateChecked)];
}

- (void)labelTappedOnSound {
    M13CheckboxState state = [m_chkPlaySound checkState];
    [m_chkPlaySound setCheckState:(state == M13CheckboxStateChecked ? M13CheckboxStateUnchecked : M13CheckboxStateChecked)];
}

- (void)labelTappedOnVibration {
    M13CheckboxState state = [m_chkUseVibration checkState];
    [m_chkUseVibration setCheckState:(state == M13CheckboxStateChecked ? M13CheckboxStateUnchecked : M13CheckboxStateChecked)];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onClickBtnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    BOOL vol = ([m_chkUseVolume checkState] == M13CheckboxStateChecked);
    BOOL snd = ([m_chkPlaySound checkState] == M13CheckboxStateChecked);
    BOOL vib = ([m_chkUseVibration checkState] == M13CheckboxStateChecked);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    Global *global = [Global sharedManager];
    if(vol != global.bUseVolume) {
        global.bUseVolume = vol;
        [prefs setObject:vol?@1:@0 forKey:UDS_KEY_USE_VOLUME_FCB];
    }
    if(snd != global.bPlaySound) {
        global.bPlaySound = snd;
        [prefs setObject:snd?@1:@0 forKey:UDS_KEY_USE_SOUND_FCB];
    }
    if(vib != global.bUseVibration) {
        global.bUseVibration = vib;
        [prefs setObject:vib?@1:@0 forKey:UDS_KEY_USE_VIBRATION_FCB];
    }
    
    [prefs synchronize];
}

@end

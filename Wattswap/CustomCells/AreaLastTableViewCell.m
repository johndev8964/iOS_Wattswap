//
//  AreaLastTableViewCell.m
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "AreaLastTableViewCell.h"
#import "APIService.h"
#import "CoredataManager.h"

@implementation AreaLastTableViewCell

@synthesize addAreaView, areaName, global, m_surveyPropertyTabPageVC;

- (void)awakeFromNib {
    // Initialization code
    self.m_btnSave.layer.cornerRadius = 5;
    areaName.delegate = self;

    global = [Global sharedManager];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) saveArea:(id)sender {
    if (areaName.text.length > 0) {
        
        // at first, save new data to local coredata
        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
        AreaInfo *newArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
        
        newArea.ofp_sid = global.floor.ofp_sid;
        newArea.sid = global.floor.sid;
        
        newArea.ofp_fid = global.floor.ofp_fid;
        newArea.fid = global.floor.fid;
        
        newArea.aid = @0;
        newArea.ofp_aid = [global getMaxAreaValue:YES];
        
        newArea.adesc = areaName.text;
        newArea.seq = [NSNumber numberWithInteger:[m_surveyPropertyTabPageVC arrangeSequenceNumber:[AreaInfo class]]];
        newArea.stime = SERVER_TIME([NSDate date]);
        
        NSError *error;
        if(NO == [coreDataContext save:&error]) {
            [m_surveyPropertyTabPageVC.view makeToast:@"Failed in adding new area. App won't work rightly."];
            return;
        }
        
        // save new data to global array
        global.areaID = newArea.ofp_aid;
        global.area = newArea;
        [global.areasArray addObject:newArea];

        if(newArea.fid.intValue != 0) {
            NSDictionary *params = @{@"survey_id":global.floor.sid, @"floor_id":global.floor.fid, @"area_name":areaName.text};
            [[APIService sharedManager] addArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                if (error == nil) {
                    NSString *statusCode = [result objectForKey:@"status"];
                    if ([statusCode isEqualToString:@"success"]) {
                        NSDictionary *area = [[result objectForKey:@"data"] firstObject];
                        newArea.aid = NFS([area objectForKey:@"area_id"]);
                        newArea.stime = [global getDateFromString:[area objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];
                        [coreDataContext save:&error];
                    }
                }
            }];
        }
        
        areaName.text = @"";
        [m_surveyPropertyTabPageVC loadAreasOfFloor:global.floor];
        [m_surveyPropertyTabPageVC goFixtureList];
    }
    else {
        [m_surveyPropertyTabPageVC.view makeToast:@"Please enter area description."];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

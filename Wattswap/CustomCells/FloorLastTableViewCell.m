//
//  FloorLastTableViewCell.m
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "FloorLastTableViewCell.h"
#import "APIService.h"
#import "CoredataManager.h"

@implementation FloorLastTableViewCell
@synthesize m_btnSave;

@synthesize addFloorView, floorName, global, m_surveyPropertyTabPageVC;

- (void)awakeFromNib {
    // Initialization code
    m_btnSave.layer.cornerRadius = 5;
    floorName.delegate = self;
    
    global = [Global sharedManager];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction) saveFloor:(id)sender {
    if (floorName.text.length > 0)
    {
        // at first, save new data to local coredata
        NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
        FloorInfo *newFloor = [NSEntityDescription insertNewObjectForEntityForName:@"FloorInfo" inManagedObjectContext:coreDataContext];
        
        newFloor.ofp_sid = global.survey.ofp_sid;
        newFloor.sid = global.survey.sid;
        
        newFloor.fid = @0;
        newFloor.ofp_fid = [global getMaxFloorValue:YES];
        newFloor.fdesc = floorName.text;
        newFloor.seq = [NSNumber numberWithInteger:[m_surveyPropertyTabPageVC arrangeSequenceNumber:[FloorInfo class]]];
        newFloor.stime = SERVER_TIME([NSDate date]);
        
        NSError *error;
        if(NO == [coreDataContext save:&error]) {
            [m_surveyPropertyTabPageVC.view makeToast:@"Failed in adding new floor. App won't work rightly."];
            return;
        }
        
        // save new data to global array
        global.floorID = newFloor.ofp_fid;
        global.floor = newFloor;
        [global.floorsArray addObject:newFloor];
        
        if(newFloor.sid.intValue != 0) {
            NSDictionary *params = @{@"survey_id":global.survey.sid, @"floor_name":floorName.text};
            [[APIService sharedManager] addFloor2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                if (error == nil) {
                    NSString *statusCode = [result objectForKey:@"status"];
                    if ([statusCode isEqualToString:@"success"]) {
                        NSDictionary *floor = [[result objectForKey:@"data"] firstObject];
                        newFloor.fid = NFS([floor objectForKey:@"floor_id"]);
                        newFloor.stime = [global getDateFromString:[floor objectForKey:@"last_modified"] Format:@"yyyy-MM-dd HH:mm:ss"];

                        [coreDataContext save:&error];
                    }
                }
            }];
        }
        
        floorName.text = @"";
        [m_surveyPropertyTabPageVC goAreaList];
    }
    else {
        [m_surveyPropertyTabPageVC.view makeToast:@"Please enter floor description."];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end

//
//  AreaTableViewCell.m
//  Wattswap
//
//  Created by User on 5/21/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "AreaTableViewCell.h"
#import "CoredataManager.h"
#import "APIService.h"

@implementation AreaTableViewCell

@synthesize areaName, numOfFixtures, btnView, index, area, areaCopyAlertView, areaDeleteAlertView;

- (void)awakeFromNib {
    // Initialization code
}

- (void) addGesture {
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(leftSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(rightSwipe:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) leftSwipe :(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    if ( btnView.center.x > 320 && btnView.center.x < 640) {
        self.btnView.center = CGPointMake(self.btnView.center.x - 270.0f, self.btnView.center.y);
    }
    
    [UIView commitAnimations];
}

- (IBAction) rightSwipe :(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    if ( btnView.center.x > 0 && btnView.center.x < 320) {
        self.btnView.center = CGPointMake(self.btnView.center.x + 270.0f, self.btnView.center.y);
    }
    
    [UIView commitAnimations];
}

- (void) btnViewSwipeRight {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    if ( btnView.center.x > 0 && btnView.center.x < 320) {
        self.btnView.center = CGPointMake(self.btnView.center.x + 270.0f, self.btnView.center.y);
    }
    
    [UIView commitAnimations];
}

- (IBAction) copyArea:(id)sender {
    areaCopyAlertView = [[UIAlertView alloc] initWithTitle:@"Area Name" message:@"Enter Area Name:" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    areaCopyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [areaCopyAlertView show];
}

- (IBAction) editArea:(id)sender {
    Global *global = [Global sharedManager];
    global.area = area;
}

- (IBAction) deleteArea:(id)sender {
    areaDeleteAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to delete this area?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [areaDeleteAlertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    if (buttonIndex == 1) {
        if ([alertView isEqual:areaDeleteAlertView]) {
            
            NSNumber *area_id = area.aid;
            NSNumber *ofp_area_id = area.ofp_aid;
            [APIService deleteObjectFromCoreData:@"FixtureInfo" Condition:@"ofp_aid==%@" FieldValue:ofp_area_id.stringValue];
            
            [global.areasArray removeObject:area];
            [coreDataContext deleteObject:area];
            
            NSError *error1;
            if(NO == [coreDataContext save:&error1]) {
                [self.superview makeToast:error1.description];
                return;
            }

            [self btnViewSwipeRight];
            
            if(area_id.intValue != 0) {
                NSDictionary *params = @{@"area_id":area_id};
                [[APIService sharedManager] deleteAreaFromServer:params onCompletion:^(NSDictionary *result, NSError *error) {
                    if (error == nil) {
                        NSString *statusCode = [result objectForKey:@"status"];
                        if (![statusCode isEqualToString:@"Success"]) {
                            [[APIService sharedManager] setObjectAsUnsync:@"Del_Area" ObjId:area_id];
                        }
                    }
                    else {
                        [[APIService sharedManager] setObjectAsUnsync:@"Del_Area" ObjId:area_id];
                    }
                }];
            }
        }
        else
        {
            UITextField* copiedName = [areaCopyAlertView textFieldAtIndex:0];
            NSDictionary *params = @{@"area_id":area.aid, @"area_name":copiedName.text};
            [[APIService sharedManager] copyArea2Server:params onCompletion:^(NSDictionary *result, NSError *error) {
                if (error == nil)
                {
                    NSString *statusCode = [result objectForKey:@"status"];
                    NSMutableDictionary* data = [result objectForKey:@"data"];
                    
                    if ([statusCode isEqualToString:@"success"])
                    {
                        NSDictionary* areaData = [[data objectForKey:@"area"] firstObject];
                        AreaInfo *newArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
                        
                        newArea.ofp_sid = area.ofp_sid;
                        newArea.sid = NFS([areaData objectForKey:@"survey_id"]);
                        newArea.ofp_fid = area.ofp_fid;
                        newArea.fid = NFS([areaData objectForKey:@"floor_id"]);
                        newArea.ofp_aid = [global getMaxAreaValue:YES];
                        newArea.aid = NFS([areaData objectForKey:@"area_id"]);
                        newArea.adesc = [areaData objectForKey:@"area_name"];
                        global.area = newArea;
                        [global.areasArray addObject:newArea];
                        
                        NSMutableDictionary* fixturesForArea = [data objectForKey:@"fixtures"];
                        for (NSDictionary *fixture in fixturesForArea)
                        {
                            FixtureInfo *newFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
                            
                            newFixture.ofp_sid = area.ofp_sid;
                            newFixture.ofp_fid = area.ofp_fid;
                            newFixture.ofp_aid = newArea.ofp_aid;
                            newFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
                            
                            [newFixture initWithDict:fixture];
                            
                            [global.fixturesArray addObject:newFixture];
                        }
                        
                        [self btnViewSwipeRight];
                        
                        NSError *error;
                        if([coreDataContext save:&error] == NO)
                        {
                            [self.superview makeToast:error.description];
                        }
                    }
                    else {
                        [self copyArea2CoreData:area CopiedName:copiedName.text];
                    }
                }
                else {
                    [self copyArea2CoreData:area CopiedName:copiedName.text];
                }
            }];
        }
    }
}

- (void)copyArea2CoreData:(AreaInfo*)areaInfo CopiedName:(NSString*)copiedName
{
    NSManagedObjectContext *coreDataContext = [[CoredataManager sharedManager] masterManagedObjectContext];
    Global *global = [Global sharedManager];
    
    AreaInfo *copiedArea = [NSEntityDescription insertNewObjectForEntityForName:@"AreaInfo" inManagedObjectContext:coreDataContext];
    copiedArea.sid = areaInfo.sid;
    copiedArea.ofp_sid = areaInfo.ofp_sid;
    copiedArea.fid = areaInfo.fid;
    copiedArea.ofp_fid = areaInfo.ofp_fid;
    copiedArea.aid = @0;
    copiedArea.ofp_aid = [global getMaxAreaValue:YES];
    copiedArea.adesc = copiedName;
    
    NSError *error;
    if([coreDataContext save:&error])
    {
        [global.areasArray addObject:copiedArea];
    }
    else {
        [self.superview makeToast:error.description];
        return;
    }
    
    NSArray *aryFixture = [APIService getObjectsFromCoreData:@"FixtureInfo" IDName:@"ofp_aid" IDValue:areaInfo.ofp_aid.stringValue];
    if(aryFixture != nil) {
        for(int j=0; j<[aryFixture count]; j++) {
            FixtureInfo *fixture = (FixtureInfo*)[aryFixture objectAtIndex:j];
            FixtureInfo *copiedFixture = [NSEntityDescription insertNewObjectForEntityForName:@"FixtureInfo" inManagedObjectContext:coreDataContext];
            copiedFixture.sid = fixture.sid;
            copiedFixture.ofp_sid = fixture.ofp_sid;
            copiedFixture.fid = fixture.fid;
            copiedFixture.ofp_fid = fixture.ofp_fid;
            copiedFixture.aid = @0;
            copiedFixture.ofp_aid = copiedArea.ofp_aid;
            copiedFixture.fixtureid = @0;
            copiedFixture.ofp_fixtureid = [global getMaxFixtureValue:YES];
            
            copiedFixture.supervisor_id = fixture.supervisor_id;
            copiedFixture.hoursperweek = fixture.hoursperweek;
            copiedFixture.hoursinyear = fixture.hoursinyear;
            copiedFixture.ballastfactor = fixture.ballastfactor;
            copiedFixture.ballasttype = fixture.ballasttype;
            copiedFixture.bulbsperfixture = fixture.bulbsperfixture;
            copiedFixture.lampcode = fixture.lampcode;
            copiedFixture.control = fixture.control;
            copiedFixture.fixturecnt = fixture.fixturecnt;
            copiedFixture.fixturetype = fixture.fixturetype;
            copiedFixture.hoursperday = fixture.hoursperday;
            copiedFixture.height = fixture.height;
            copiedFixture.mounting = fixture.mounting;
            copiedFixture.note = fixture.note;
            copiedFixture.option = fixture.option;
            copiedFixture.path = fixture.path;
            copiedFixture.style = fixture.style;
            copiedFixture.daysperweek = fixture.daysperweek;
            copiedFixture.wattsperbulb = fixture.wattsperbulb;
            copiedFixture.ofp_path = fixture.ofp_path;
            
            if([coreDataContext save:&error])
            {
                [global.fixturesArray addObject:copiedFixture];
            }
            else {
                [self.superview makeToast:error.description];
                return;
            }
        }
    }
    
    [self btnViewSwipeRight];
}

@end

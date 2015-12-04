//
//  DetailedFixtureViewController.m
//  Wattswap
//
//  Created by User on 5/26/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "DetailedFixtureViewController.h"
#import "ConversionCollectionCell.h"

#import "APIService.h"

@interface DetailedFixtureViewController ()
{
    NSIndexPath *curSelectedIndex;
}

@end

@implementation DetailedFixtureViewController

@synthesize fixtureCntText, hoursPerWeekText, fixtureTypeStyleNameText, fixtureWattsText, aryConversions, fixtureLamp, fixtureType, collectionViewConversionCandiates, conversionInfo, replacement_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(rightSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    // get conversionlist from local db based on survey type and survey code
    NSRange range = [fixtureLamp rangeOfString:@","];
    if(range.length > 0) {
        NSString *realWatts = [fixtureLamp substringFromIndex:range.location+1];
        if(realWatts.intValue > 0) {
            fixtureLamp = [fixtureLamp substringToIndex:range.location];
        }
    }
//    aryConversions = [APIService getObjectsFromCoreData:@"RetrofitInfo" Where:[NSString stringWithFormat:@"retrofit_old_fixture_type == \"%@'\", fixtureType]];
    aryConversions = [APIService getObjectsFromCoreData:@"RetrofitInfo" Where:[NSString stringWithFormat:@"retrofit_old_fixture_type == \"%@\" and retrofit_old_lamp == \"%@\"", fixtureType, fixtureLamp]];
    if(replacement_id != 0) {
        for(int i=0; i<[aryConversions count]; i++) {
            RetrofitInfo *one = [aryConversions objectAtIndex:i];
            if(one.retrofit_id.intValue == replacement_id)
            {
                conversionInfo = one;
                curSelectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
                [collectionViewConversionCandiates selectItemAtIndexPath:curSelectedIndex animated:YES scrollPosition:UICollectionViewScrollPositionTop];
                break;
            }
        }
    }
    
    [self calcBasedOnConversionCandidate:conversionInfo];
}

- (void)calcBasedOnConversionCandidate:(RetrofitInfo*)conversion
{
    Global *global = [Global sharedManager];
    
    self.lblFixtureCnt.text = fixtureCntText;
    self.lblFixtureWatts.text = fixtureWattsText;
    self.lblFixtureHours.text = hoursPerWeekText;
    self.lblFixtureStyleName.text = fixtureTypeStyleNameText;
    self.lblTitle.text = [NSString stringWithFormat:@"ROI & Energy Savings @ kWh $%.2f", global.survey.rateperwatt.floatValue];
    
    int hours = 0, watts = 0, cnt = 0;
    float rate = (float)global.survey.rateperwatt.floatValue;
    if(hoursPerWeekText != nil && hoursPerWeekText.length > 0)
        hours = (int)(hoursPerWeekText.integerValue);
    if(fixtureWattsText != nil && fixtureWattsText.length > 0)
        watts = fixtureWattsText.intValue;
    cnt = (int)fixtureCntText.integerValue;
    float total = (float)(rate * hours * watts * cnt * 52 / 1000);
    [self.lblTotalCost setText:[NSString stringWithFormat:@"$%.2f", total]];
    
    conversionInfo = conversion;
    // calc based on conversion selected
    if(conversionInfo != nil) {
        [self.lblTutorial setHidden:YES];
        
        watts = conversion.retrofit_real_lamp_wattage.intValue;
        self.lblFixtureWattsC.text = [NSString stringWithFormat:@"%d", watts];
        self.lblFixtureCntC.text = fixtureCntText;
        self.lblFixtureHoursC.text = hoursPerWeekText;
        float total1 = (float)(rate * hours * watts * cnt * 52 / 1000);
        [self.lblTotalCostC setText:[NSString stringWithFormat:@"$%.2f", total1]];
        
        self.lblTotalSaving.text = [NSString stringWithFormat:@"$%.2f", total > 0 ?(total - total1) : 0];
    }
}

- (IBAction)rightSwipe:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%d", (int)aryConversions.count);
    return aryConversions.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RetrofitInfo *conversion = [aryConversions objectAtIndex:indexPath.row];
    ConversionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexPath.row % 2 == 0 ? @"ConversionCollectionCell1" : @"ConversionCollectionCell2" forIndexPath:indexPath];

    if(curSelectedIndex != nil) {
        cell.layer.borderColor = UIColorFromRGBValue(0x6ed1ec).CGColor;
        cell.layer.cornerRadius = 2.0f;
        cell.layer.masksToBounds = YES;
        if(curSelectedIndex.row != indexPath.row) {
            cell.layer.borderWidth = 0.0f;
        } else {
            cell.layer.borderWidth = 5.0f;
        }
    }
    
    cell.m_lblConversionName.text = conversion.retrofit_ballast;
    NSString *fullImagePath = [[[Global sharedManager] wattSwapDirectory] stringByAppendingPathComponent: CONVERSION_CANDI_IMAGE_NAME(conversion.retrofit_id.stringValue)];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:fullImagePath])
    {
        [cell.m_imgConversionCandidate setImageWithURL:[NSURL fileURLWithPath:fullImagePath]];
    }
    else
    {
        __weak ConversionCollectionCell *weakCell = cell;
        [cell.m_imgConversionCandidate setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:conversion.retrofit_image]]
                       placeholderImage:nil
            usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite
                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                    weakCell.m_imgConversionCandidate.image = image;
                                    
                                    dispatch_async(APP_CUSTOM_QUEUE, ^{
                                        
                                        [Global createFileWithName:CONVERSION_CANDI_IMAGE_NAME(conversion.retrofit_id.stringValue) FromImage:image];
                                    });
                                }
                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                    NSLog(@"%@", error.description);
                                }];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RetrofitInfo *conversion = [aryConversions objectAtIndex:indexPath.row];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didChangedReplacement:)]) {
        if(indexPath.row == curSelectedIndex.row)
            [self.delegate didChangedReplacement:0];
        else
            [self.delegate didChangedReplacement:conversion.retrofit_id.intValue];
    }
    
    [self calcBasedOnConversionCandidate:conversion];
  
    if(curSelectedIndex != nil) {
        ConversionCollectionCell *cellVisible = (ConversionCollectionCell *)[collectionView cellForItemAtIndexPath:curSelectedIndex];
        cellVisible.layer.borderColor = UIColorFromRGBValue(0x6ed1ec).CGColor;
        cellVisible.layer.cornerRadius = 2.0f;
        cellVisible.layer.masksToBounds = YES;
        cellVisible.layer.borderWidth = 0.0f;
        NSIndexPath *oldPath = curSelectedIndex;
        curSelectedIndex = nil;
        if(oldPath.row == indexPath.row)
            return;
    }
    
    ConversionCollectionCell *curCell = (ConversionCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    curCell.layer.borderColor = UIColorFromRGBValue(0x6ed1ec).CGColor;
    curCell.layer.cornerRadius = 2.0f;
    curCell.layer.masksToBounds = YES;
    curCell.layer.borderWidth = 5.0f;
    curSelectedIndex = indexPath;
}


@end

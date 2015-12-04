//
//  AddFixtureCheckTableViewCell.m
//  Wattswap
//
//  Created by User on 5/25/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "AddFixtureCheckTableViewCell.h"
#import "NewFixtureViewController.h"

@implementation AddFixtureCheckTableViewCell

@synthesize fixtureTypeLabel, checkImageView, addFixtureCtrl;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setCheckStatus:(BOOL) status {
    
    UIImage *checkedImage = [UIImage imageNamed:@"checked"];
    UIImage *uncheckedImage = [UIImage imageNamed:@"unchecked"];
    
    if (status) {
        [checkImageView setImage:checkedImage];
    } else {
        [checkImageView setImage:uncheckedImage];
    }
}

- (IBAction)itemCheck:(id)sender {
    NSData *imageViewImageData = UIImageJPEGRepresentation(checkImageView.image, 0.7f);
    
    UIImage *checkedImage = [UIImage imageNamed:@"checked"];
    NSData *checkedImageData = UIImageJPEGRepresentation(checkedImage, 0.7f);
    
    UIImage *uncheckedImage = [UIImage imageNamed:@"unchecked"];
    
    if (![imageViewImageData isEqualToData:checkedImageData]) {
        [checkImageView setImage:checkedImage];
        [addFixtureCtrl.checkList addObject:fixtureTypeLabel.text];
    }
    else {
        [checkImageView setImage:uncheckedImage];
        [addFixtureCtrl.checkList removeObject:fixtureTypeLabel.text];
    }
}

@end

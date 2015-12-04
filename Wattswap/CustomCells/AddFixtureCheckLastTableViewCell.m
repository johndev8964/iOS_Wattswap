//
//  AddFixtureCheckLastTableViewCell.m
//  Wattswap
//
//  Created by MY on 8/5/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "AddFixtureCheckLastTableViewCell.h"

@implementation AddFixtureCheckLastTableViewCell

@synthesize otherOption, checkImageView, fixtureListCtrl;

- (void)awakeFromNib {
    // Initialization code
    [otherOption setDelegate:self];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
    
    // Specify that the gesture must be a single tap
    tapRecognizer.numberOfTapsRequired = 1;
    
    // Add the tap gesture recognizer to the view
    [checkImageView addGestureRecognizer:tapRecognizer];
    [checkImageView setUserInteractionEnabled:YES];
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

- (void) respondToTapGesture:(UITapGestureRecognizer*) recognizer
{
    NSData *imageViewImageData = UIImageJPEGRepresentation(checkImageView.image, 0.7f);
    
    UIImage *checkedImage = [UIImage imageNamed:@"checked"];
    NSData *checkedImageData = UIImageJPEGRepresentation(checkedImage, 0.7f);
    
    UIImage *uncheckedImage = [UIImage imageNamed:@"unchecked"];
    
    if (![imageViewImageData isEqualToData:checkedImageData]) {
        [checkImageView setImage:checkedImage];
        [fixtureListCtrl.checkList addObject:otherOption.text];
    }
    else {
        [checkImageView setImage:uncheckedImage];
        [fixtureListCtrl.checkList removeObject:otherOption.text];
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:fixtureListCtrl.selectedIndex inSection:0];
//    [fixtureListCtrl.fixtureTypeListTable deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([otherOption.text isEqualToString:@"Other"]) {
        [fixtureListCtrl.checkList removeObject:otherOption.text];
        otherOption.text = @"";
    }
    if([otherOption.text isEqualToString:@""]== NO)
        [fixtureListCtrl.checkList removeObject:otherOption.text];
    
    //[self setSelected:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([otherOption.text isEqualToString:@""]) {
        otherOption.text = @"Other";
    }
    
    NSData *imageViewImageData = UIImageJPEGRepresentation(checkImageView.image, 0.7f);
    
    UIImage *checkedImage = [UIImage imageNamed:@"checked"];
    NSData *checkedImageData = UIImageJPEGRepresentation(checkedImage, 0.7f);
    
    if([imageViewImageData isEqualToData:checkedImageData])
        [fixtureListCtrl.checkList addObject:otherOption.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

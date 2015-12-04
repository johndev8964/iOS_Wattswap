//
//  PreviewHtmlViewController.h
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewHtmlViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *htmlView;
@property (nonatomic, retain) NSString *htmlString;

- (IBAction) goBack:(id)sender;

@end

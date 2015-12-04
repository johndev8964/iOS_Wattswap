//
//  Sync2Server.h
//  Wattswap
//
//  Created by MY on 8/28/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Sync2ServerDelegate <NSObject>

@optional

- (void) didFinished2RtDBWithResult:(NSString*)result Error:(NSError *)error; // call at the end of processing
- (void) didFinished2LcDBWithResult:(NSString*)result Error:(NSError *)error; // call at the end of processing

@end

@interface Sync2Server : NSObject

@property (nonatomic, retain) id<Sync2ServerDelegate> delegate;

@property (nonatomic, readwrite) BOOL isProcessing;
@property (nonatomic, readwrite) BOOL isUploading;
@property (nonatomic, readwrite) int iRequestCount;

+ (instancetype) sharedSyncManager;

- (BOOL)startSync2RtDB;
- (BOOL)startSync2LcDB;

@end

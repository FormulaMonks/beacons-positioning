//
//  CBBeaconsHelper.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/20/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBBeaconsHelper;

@protocol CBBeaconsHelperDelegate
- (void)helperDidFinishLog:(CBBeaconsHelper *)helper;

// NSArray of CBSignal
- (void)helper:(CBBeaconsHelper *)helper didReadBeaconsFromLog:(NSArray *)signals;
@end

@interface CBBeaconsHelper : NSObject

@property (weak) id<CBBeaconsHelperDelegate>delegate;

- (CGSize)roomSize;
- (NSMutableArray *)loadBeacons;

- (void)initLogTimers;
- (void)appendToLog:(NSArray *)signals;
- (void)saveLog;

- (void)saveBeacons:(NSArray *)beacons;
- (void)deleteBeacons;

- (void)playLog:(NSArray *)signals;
- (void)stopPlayingLog;

@end

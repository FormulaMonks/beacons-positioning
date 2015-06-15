//
//  CBBeaconsRanger.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/17/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBBeaconsRanger;

@protocol CBBeaconsRangerDelegate
// NSArray of CBSignal
- (void)beaconsRanger:(CBBeaconsRanger *)ranger didRangeBeacons:(NSArray *)signals;
@end

@interface CBBeaconsRanger : NSObject

@property (nonatomic, weak) id<CBBeaconsRangerDelegate> delegate;
@property NSString *uuid;

// array of NSNumber
@property NSArray *minorsFilter; // only log this minors

- (BOOL)startRanging;
- (void)stopRanging;

@end

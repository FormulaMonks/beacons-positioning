//
//  CBBeaconsRanger.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/17/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBSignal : NSObject
@property NSNumber *distance;
@property NSNumber *minor;
@property NSNumber *major;
@property NSNumber *rssi;
@end

@class CBBeaconsRanger;

@protocol CBBeaconsRangerDelegate
// array of CBSignal
- (void)beaconsRanger:(CBBeaconsRanger *)ranger didRangeBeacons:(NSArray *)signals;
@end

@interface CBBeaconsRanger : NSObject

@property (nonatomic, weak) id<CBBeaconsRangerDelegate> delegate;
@property NSString *uuid;

- (void)startRanging;
- (void)stopRanging;

@end

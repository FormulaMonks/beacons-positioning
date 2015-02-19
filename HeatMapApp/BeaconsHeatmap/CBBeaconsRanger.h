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
// array of NSDictionary (distance, minor, major, rssi) instances
- (void)beaconsRanger:(CBBeaconsRanger *)ranger didRangeBeacons:(NSArray *)beacons;
@end

@interface CBBeaconsRanger : NSObject

@property (nonatomic, weak) id<CBBeaconsRangerDelegate> delegate;
@property NSString *uuid;

- (void)startRanging;
- (void)stopRanging;

@end

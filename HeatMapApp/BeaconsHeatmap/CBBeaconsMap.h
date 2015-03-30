//
//  BeaconsMap.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBEstimationMethod.h"

@class CBBeaconsMap;

@protocol CBBeaconsMapDelegate
// array of CGPoints
- (void)beaconMap:(CBBeaconsMap *)beaconMap lastMeasuredPoints:(NSArray *)points;

// array of CBBeacon
- (void)beaconMap:(CBBeaconsMap *)beaconMap beaconsPropertiesChanged:(NSArray *)beacons;
@end

@interface CBBeaconsMap : UIView

@property CGSize physicalSize;

@property (weak) id<CBBeaconsMapDelegate> delegate;

@property NSMutableArray *beacons;

@property CBEstimationMethod method;

@property CBDrawMethod drawMethod;

// will look for updates
- (void)updateBeacons;

// to clean any noise cancelling history
- (void)resetPreviousData;

@end

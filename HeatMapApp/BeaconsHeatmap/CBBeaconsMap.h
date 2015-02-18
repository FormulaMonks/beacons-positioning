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
- (void)beaconMap:(CBBeaconsMap *)beaconMap probabilityPointsUpdated:(NSArray *)points;

// array of CBBeacon
- (void)beaconMap:(CBBeaconsMap *)beaconMap beaconsPropertiesChanged:(NSArray *)beacons;
@end

@interface CBBeacon : NSObject <NSCoding>
@property CGPoint position;
@property float distance;
@property NSString *name;

- (instancetype)initWithX:(float)x y:(float)y distance:(float)distance;

@end

@interface CBBeaconsMap : UIView

@property CGSize physicalSize;

@property (weak) id<CBBeaconsMapDelegate> delegate;

@property NSArray *beacons;

@property CBEstimationMethod method;

// will look for updates
- (void)updateBeacons;

@end

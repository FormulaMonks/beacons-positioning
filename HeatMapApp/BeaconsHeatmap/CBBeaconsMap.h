//
//  BeaconsMap.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBBeaconsMap;

@protocol CBBeaconsMapDelegate
// array of CGPoints
- (void)beaconMap:(CBBeaconsMap *)beaconMap probabilityPointsUpdated:(NSArray *)points;
@end

@interface CBBeacon : NSObject
@property CGPoint position;
@property float distance;

- (instancetype)initWithX:(float)x y:(float)y distance:(float)distance;

@end

@interface CBBeaconsMap : UIView

@property (weak) id<CBBeaconsMapDelegate> delegate;

@property NSArray *beacons;

// will look for updates
- (void)updateBeacons;

@end

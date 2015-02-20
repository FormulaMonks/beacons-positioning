//
//  CBBeaconsSimulator.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBBeaconsSimulator.h"
#import "CBBeacon.h"

const float kRefreshTime = 0.1;

@interface CBBeaconsSimulator()
@property NSArray *beacons;
@property float noise;
@end

@implementation CBBeaconsSimulator

- (void)simulateBeacons:(NSArray *)beacons noise:(float)percentageNoise {
    _beacons = beacons;
    _noise = percentageNoise;
    
    [self performSelector:@selector(moveLoop) withObject:nil afterDelay:kRefreshTime];
}

- (void)stopSimulation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)moveLoop {
    for (CBBeacon *beacon in _beacons) {
        float delta = beacon.distance * _noise;
        int multDelta = (int)(delta * 112);
        if (multDelta > 0) {
            float r = -delta/2 + (arc4random() % multDelta)/100.0;
            beacon.distance += r;
        }
    }
    
    [_delegate beaconSimulatorDidChange:self];
    
    [self performSelector:@selector(moveLoop) withObject:nil afterDelay:kRefreshTime];
}

@end

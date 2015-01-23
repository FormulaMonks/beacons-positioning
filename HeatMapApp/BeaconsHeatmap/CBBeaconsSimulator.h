//
//  CBBeaconsSimulator.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBBeaconsSimulator;

@protocol CBBeaconsSimulatorDelegate
-(void)beaconSimulatorDidChange:(CBBeaconsSimulator *)simulator;
@end

@interface CBBeaconsSimulator : NSObject

@property (weak) id <CBBeaconsSimulatorDelegate> delegate;

- (void)simulateBeacons:(NSArray *)beacons noise:(float)percentageNoise;
- (void)stopSimulation;

@end

//
//  CBBeaconsRanger.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/17/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

//#import "SIOSocket.h"
#import "CBBeaconsRanger.h"
#import <CoreLocation/CoreLocation.h>
#import "CBBeacon.h"

@interface CBBeaconsRanger() <CLLocationManagerDelegate>
//@property SIOSocket *socket;
@property CLLocationManager *locationManager;
@property CLBeaconRegion *beaconRegion;
@property BOOL ranging;
@end

@implementation CBBeaconsRanger

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
//        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    

    return self;
}

- (BOOL)startRanging {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:_uuid];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.citrusbyte"];
    
    if (![CLLocationManager isRangingAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry but ranging beacons is not supported on this device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];

        return NO;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please first authorize to locate your beacons from iOS Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    _ranging = YES;
    
    if (self.beaconRegion) {
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    
    return YES;
}

- (void)stopRanging {
    _ranging = NO;
    
    if (self.beaconRegion) {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

# pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringForRegion");
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Did change authorization with status %d", status);
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (_ranging && self.beaconRegion) {
            [self.locationManager startMonitoringForRegion:self.beaconRegion];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            NSLog(@"Region inside");
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            break;
        case CLRegionStateOutside:
            NSLog(@"Region outside");
            break;
        case CLRegionStateUnknown:
            NSLog(@"Region unknown");
            break;
        default:
            NSLog(@"Region unknown");
    }
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSMutableArray *beaconsArray = [NSMutableArray array];
    for(CLBeacon *beacon in beacons) {
        if (_minorsFilter && [_minorsFilter count] > 0 && ![_minorsFilter containsObject:beacon.minor]) {
            continue;
        }
        if (beacon.accuracy > 0) {
            CBSignal *signal = [CBSignal new];
            signal.minor = beacon.minor;
            signal.major = beacon.major;
            signal.rssi = [NSNumber numberWithInteger:beacon.rssi];
            signal.distance = [NSNumber numberWithDouble:beacon.accuracy];
            signal.proximity = beacon.proximity;
            [beaconsArray addObject:signal];
        }
    }
    
    [_delegate beaconsRanger:self didRangeBeacons:beaconsArray];
}

//- (void)initSocket {
//    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
//        _socket = socket;
//        _socket.onConnect = ^(void) {
//            NSLog(@"socket connected.");
//        };
//        [_socket on:@"update" callback:^(NSArray *args) {
//            NSArray *devices = args[0];
//            for (CBBeacon *beacon in _beaconsView.beacons) {
//                for (NSDictionary *item in devices) {
//                    if (beacon.name == nil || [beacon.name isEqualToString:item[@"name"]]) { // in case it's empty assign the first empty
//                        beacon.name = item[@"name"];
//                        beacon.distance = [item[@"distance"] floatValue];
//                    }
//                }
//                
//                [_beaconsView updateBeacons];
//            }
//        }];
//    }];
//}

@end

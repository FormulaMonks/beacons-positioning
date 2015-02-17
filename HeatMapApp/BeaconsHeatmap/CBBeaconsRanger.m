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

#define kGeLoProfileUUID "11E44F09-4EC4-407E-9203-CF57A50FBCE0"

@interface CBBeaconsRanger() <CLLocationManagerDelegate>
//@property SIOSocket *socket;
@property CLLocationManager *locationManager;
@property CLBeaconRegion *beaconRegion;
@end

@implementation CBBeaconsRanger

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@kGeLoProfileUUID];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.gelosite"];
    }
    
    return self;
}

- (void)startRanging {
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)stopRanging {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

# pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            NSLog(@"Region unknown");
    }
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSUInteger beaconIdentifier;
    for(CLBeacon *beacon in beacons){
        // create a identifier for the major|minor that we can use to compare beacons
        beaconIdentifier = (beacon.major.unsignedIntegerValue << 16) | (beacon.minor.unsignedIntegerValue);
        
        NSLog(@"beacon %@: %fm", beacon.minor, beacon.accuracy);
    }
    
    [_delegate beaconsRanger:self didRangeBeacons:beacons];
    
    NSLog(@"-");
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

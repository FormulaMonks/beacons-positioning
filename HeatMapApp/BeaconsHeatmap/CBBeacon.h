//
//  CBBeacon.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/20/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CBSignal : NSObject
@property NSNumber *distance;
@property NSNumber *minor;
@property NSNumber *major;
@property NSNumber *rssi;
@property CLProximity proximity;
@end

@interface CBBeacon : NSObject <NSCoding>
@property CGPoint position; // pixels
@property float distance; // meters
@property NSNumber *minor;
@property NSString *name;
@property NSInteger rssi;
@property CLProximity proximity;

- (instancetype)initWithX:(float)x y:(float)y distance:(float)distance;

@end
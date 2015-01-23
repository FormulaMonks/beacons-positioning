//
//  BeaconsMap.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBBeaconsMap.h"

const float kGap = 10.0;

@interface CBBeaconsMap()
@property CBBeacon *nearestBeacon;
@end

@implementation CBBeaconsMap

- (void)awakeFromNib {
    [self calculateProbabilityPoints];
}

- (void)calculateProbabilityPoints {
    NSMutableArray *points = [NSMutableArray array];
    for (int x = 0; x < self.bounds.size.width; x += kGap) {
        for (int y = 0; y < self.bounds.size.height; y += kGap) {
            int intersectionCount = 0;
            for (CBBeacon *beacon in _beacons) {
                float dx = beacon.position.x - x;
                float dy = beacon.position.y - y;
                if (dx*dx + dy*dy <= beacon.distance * beacon.distance) {
                    intersectionCount++;
                }
            }
            
            if (intersectionCount == _beacons.count) {
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        }
    }
    
    [_delegate probabilityPointsUpdated:points];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    CGContextSetLineWidth(ctx,3);
    CGContextSetRGBStrokeColor(ctx,0.8,0.8,0.8,1.0);
    
    for (CBBeacon *beacon in _beacons) {
        CGContextFillRect(ctx, CGRectMake(beacon.position.x - 10, beacon.position.y - 10, 20, 20));
        
        CGContextAddArc(ctx,beacon.position.x,beacon.position.y,beacon.distance,0.0,M_PI*2,YES);
        CGContextStrokePath(ctx);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CBBeacon *nearest = nil;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    for (CBBeacon *beacon in _beacons) {
        if (nearest == nil) {
            nearest = beacon;
        } else {
            float dx = beacon.position.x - location.x;
            float dy = beacon.position.y - location.y;
            float ndx = nearest.position.x - location.x;
            float ndy = nearest.position.y - location.y;
            if (dx*dx + dy*dy < ndx*ndx + ndy*ndy) {
                nearest = beacon;
            }
        }
    }
    
    _nearestBeacon = nearest;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    
    _nearestBeacon.distance += prevLocation.y - location.y;
    [self setNeedsDisplay];
    
    [self calculateProbabilityPoints];
}

@end

@implementation CBBeacon

- (instancetype)initWithX:(float)x y:(float)y distance:(float)distance {
    self = [super init];
    if (self) {
        _position.x = x;
        _position.y = y;
        _distance = distance;
    }
    
    return self;
}

@end
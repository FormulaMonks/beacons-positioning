//
//  BeaconsMap.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBBeaconsMap.h"

const float kGap = 10.0;
const float kDistanceToRecognizeBeaconTouch = 50.0;

@interface CBBeaconsMap()
@property CBBeacon *nearestBeacon;
@property BOOL moveBeacon;
@end

@implementation CBBeaconsMap

NSArray *_beacons;

- (void)calculateProbabilityPoints {
    NSMutableArray *insidePoints = [NSMutableArray array];
    NSMutableArray *outsidePoints = [NSMutableArray array];
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
                [insidePoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            } else if (intersectionCount == 0) {
                [outsidePoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        }
    }
    
    if (insidePoints.count > 0) {
        [_delegate beaconMap:self probabilityPointsUpdated:insidePoints];
    } else {
        [_delegate beaconMap:self probabilityPointsUpdated:outsidePoints];
    }
}

- (NSArray *)beacons {
    return _beacons;
}

- (void)setBeacons:(NSArray *)beacons {
    _beacons = beacons;
    
    [self calculateProbabilityPoints];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    for (CBBeacon *beacon in _beacons) {
        if (_moveBeacon && _nearestBeacon == beacon) {
            CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
        } else {
            CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
        }
        
        float beaconSize = 20;
        UIFont *font= [UIFont systemFontOfSize:12.0];
        if (beacon.name) {
            CGPoint nameLocation;
            if (beacon.position.x <= beaconSize) {
                nameLocation.x = beacon.position.x + beaconSize/2 + 2;
                nameLocation.y = beacon.position.y - beaconSize/2;
            }
            else if (self.bounds.size.width - beacon.position.x <= beaconSize) {
                nameLocation.x = beacon.position.x - [beacon.name sizeWithAttributes:@{NSFontAttributeName:font}].width - beaconSize/2 -  2;
                nameLocation.y = beacon.position.y - beaconSize/2;
            }
            else if (beacon.position.y <= beaconSize) {
                nameLocation.x = beacon.position.x - [beacon.name sizeWithAttributes:@{NSFontAttributeName:font}].width/2;
                nameLocation.y = [beacon.name sizeWithAttributes:@{NSFontAttributeName:font}].height;
            }
            else if (self.bounds.size.height - beacon.position.y <= beaconSize) {
                nameLocation.x = beacon.position.x - [beacon.name sizeWithAttributes:@{NSFontAttributeName:font}].width/2;
                nameLocation.y = beacon.position.y - [beacon.name sizeWithAttributes:@{NSFontAttributeName:font}].height - beaconSize/2 - 2;
            }
            [beacon.name drawAtPoint:nameLocation withAttributes:@{NSFontAttributeName:font}];
        }
        
        CGContextFillRect(ctx, CGRectMake(beacon.position.x - beaconSize/2, beacon.position.y - beaconSize/2, beaconSize, beaconSize));
        
        CGContextSetLineWidth(ctx,1);
        CGContextSetRGBStrokeColor(ctx,0.8,0.8,0.8,1.0);

        CGContextAddArc(ctx,beacon.position.x,beacon.position.y,beacon.distance,0.0,M_PI*2,YES);
        CGContextStrokePath(ctx);
    }
}

- (void)updateBeacons {
    [self calculateProbabilityPoints];
    
    [self setNeedsDisplay];
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
    
    float ndx = nearest.position.x - location.x;
    float ndy = nearest.position.y - location.y;
    
    if (sqrt(ndx*ndx + ndy*ndy) < kDistanceToRecognizeBeaconTouch) {
        _moveBeacon = YES;
    } else {
        _moveBeacon = NO;
    }
    
    _nearestBeacon = nearest;
}

- (void)processTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    
    if (_moveBeacon && _nearestBeacon) {
        _nearestBeacon.position = CGPointMake(_nearestBeacon.position.x - (prevLocation.x - location.x), _nearestBeacon.position.y - (prevLocation.y - location.y));
    } else { // move distance
        _nearestBeacon.distance += prevLocation.y - location.y;
    }
    
    [self calculateProbabilityPoints];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self processTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _nearestBeacon = nil;

    [self processTouches:touches withEvent:event];
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
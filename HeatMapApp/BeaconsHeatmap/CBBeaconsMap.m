//
//  BeaconsMap.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBBeaconsMap.h"
#import "LocationManager.h"

const float kGap = 10.0;
const float kOptimisticValue = 2.0; // 1.0 would be pessimist
const float kDistanceToRecognizeBeaconTouch = 30.0;

@interface CBBeaconsMap()
@property CBBeacon *nearestBeacon;
@property BOOL moveBeacon;
@property CGPoint estimatedPosition;
@end

@implementation CBBeaconsMap

NSArray *_beacons;

- (void)calculateProbabilityPointsManual {
    float delta = 0.05; // meters
    CGPoint minErrorPoint;
    float minError = 1000.0f;
    
    for (float x = 0; x < _physicalSize.width; x = x + delta) {
        for (float y = 0; y < _physicalSize.height; y = y + delta) {
            float error = 0.0;
            for (CBBeacon *beacon in _beacons) {
                float dx = beacon.position.x/[self pixelScaleX] - x;
                float dy = beacon.position.y/[self pixelScaleY] - y;
                float beaconToPoint = sqrt(dx*dx + dy*dy);
                float diff = beaconToPoint - beacon.distance;
                error += fabs(diff);
            }
            
            if (error < minError) {
                minError = error;
                minErrorPoint = CGPointMake(x, y);
            }
        }
    }
    
    _estimatedPosition = CGPointMake(minErrorPoint.x * [self pixelScaleX], minErrorPoint.y * [self pixelScaleY]);
    
    [_delegate beaconMap:self probabilityPointsUpdated:[self heatmapPoints]];
}

- (void)calculateProbabilityPointsLeastLibrary {
    [LocationManager determine:_beacons success:^(CGPoint location) {
        _estimatedPosition = location;

        NSArray *insidePoints = [self heatmapPoints];

        [_delegate beaconMap:self probabilityPointsUpdated:insidePoints];

    } failure:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)calculateProbabilityPoints {
    [self calculateProbabilityPointsManual];
}

- (NSArray *)heatmapPoints {
    float error = 0;
    for (CBBeacon *beacon in _beacons) {
        float dx = beacon.position.x - _estimatedPosition.x;
        float dy = beacon.position.y - _estimatedPosition.y;
        float beaconToEstimate = sqrt(dx*dx + dy*dy);
        float diff = beaconToEstimate - [self pixelDistanceFor:beacon];
        error = MAX(error, fabs(diff/kOptimisticValue));
    }
    
    NSMutableArray *insidePoints = [NSMutableArray array];
    for (int x = 0; x < self.bounds.size.width; x += kGap) {
        for (int y = 0; y < self.bounds.size.height; y += kGap) {
            float dx = _estimatedPosition.x - x;
            float dy = _estimatedPosition.y - y;
            if (sqrt(dx*dx + dy*dy) <= error) {
                [insidePoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        }
    }

    return insidePoints;
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
    NSAssert(_physicalSize.width != 0, @"physical width can't be zero");
    NSAssert(_physicalSize.height != 0, @"physical height can't be zero");

    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    float beaconSize = 20;
    UIFont *font= [UIFont systemFontOfSize:11.0];
    for (CBBeacon *beacon in _beacons) {
        if (_moveBeacon && _nearestBeacon == beacon) {
            CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
        } else {
            CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
        }
        
        if (beacon.name) {
            CGPoint nameLocation;
            NSString *label = [NSString stringWithFormat:@"%@ (%.2fm)", beacon.name, beacon.distance];
            CGSize labelSize = [label sizeWithAttributes:@{NSFontAttributeName:font}];
            if (beacon.position.x <= beaconSize * 2) {
                nameLocation.x = beacon.position.x + beaconSize/2 + 2;
                nameLocation.y = beacon.position.y - beaconSize/2;
            }
            else if (self.bounds.size.width - beacon.position.x <= beaconSize * 2) {
                nameLocation.x = beacon.position.x - labelSize.width - beaconSize/2 -  2;
                nameLocation.y = beacon.position.y - beaconSize/2;
            }
            else if (beacon.position.y <= beaconSize * 2) {
                nameLocation.x = beacon.position.x - labelSize.width/2;
                nameLocation.y = labelSize.height;
            }
            else if (self.bounds.size.height - beacon.position.y <= beaconSize * 2) {
                nameLocation.x = beacon.position.x - labelSize.width/2;
                nameLocation.y = beacon.position.y - labelSize.height - beaconSize/2 - 2;
            }
            [label drawAtPoint:nameLocation withAttributes:@{NSFontAttributeName:font}];
        }
        
        CGContextFillRect(ctx, CGRectMake(beacon.position.x - beaconSize/2, beacon.position.y - beaconSize/2, beaconSize, beaconSize));
        
        CGContextSetLineWidth(ctx,1);
        CGContextSetRGBStrokeColor(ctx,0.8,0.8,0.8,1.0);
        
        CGContextAddArc(ctx, beacon.position.x, beacon.position.y, [self pixelDistanceFor:beacon], 0.0, M_PI*2, YES);
        CGContextStrokePath(ctx);
    }
    
    CGContextSetAlpha(ctx, 0.5);
    NSString *roomWidth = [NSString stringWithFormat:@"room size: %.2fm x %.2fm", _physicalSize.width, _physicalSize.height];
    [roomWidth drawAtPoint:CGPointMake(5,  20) withAttributes:@{NSFontAttributeName:font}];
    
    float deviceSize = 10;
    if (_estimatedPosition.x && _estimatedPosition.y) {
        CGContextSetFillColorWithColor(ctx, [[UIColor greenColor] CGColor]);
        
        CGContextFillRect(ctx, CGRectMake(_estimatedPosition.x - deviceSize/2, _estimatedPosition.y - deviceSize/2, deviceSize, deviceSize));
    }
}

- (float)pixelScaleX {
    return self.bounds.size.width/_physicalSize.width;
}

- (float)pixelScaleY {
    return self.bounds.size.height/_physicalSize.height;
}

- (float)pixelScale {
    return ([self pixelScaleX] + [self pixelScaleY]) / 2.0;
}

- (float)pixelDistanceFor:(CBBeacon *)beacon {
    float scale = [self pixelScale];
    return beacon.distance * scale;
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
        _nearestBeacon.distance += (prevLocation.y - location.y) / [self pixelScale];
    }
    
    [self calculateProbabilityPoints];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self processTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _nearestBeacon = nil;
    _moveBeacon = NO;
    
    [_delegate beaconMap:self beaconsPropertiesChanged:_beacons];

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

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        _name = [decoder decodeObjectForKey:@"name"];
        _position = [[decoder decodeObjectForKey:@"position"] CGPointValue];
        _distance = [[decoder decodeObjectForKey:@"distance"] floatValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    if (_name) {
        [encoder encodeObject:_name forKey:@"name"];        
    }
    [encoder encodeObject:[NSValue valueWithCGPoint:_position] forKey:@"position"];
    [encoder encodeObject:[NSNumber numberWithFloat:_distance] forKey:@"distance"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%.1f, %1.f): %.2fm", _name, _position.x, _position.y, _distance];
}

@end
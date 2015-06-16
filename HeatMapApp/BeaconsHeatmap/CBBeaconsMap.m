//
//  BeaconsMap.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/23/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBBeaconsMap.h"
#import "LocationManager.h"
#import "CBBeacon.h"

const float kDistanceToRecognizeBeaconTouch = 30.0;
const int kAverageElements = 20;
const float kGapDistance = 0.05; // meters
const int kErrorHeatmapRadiusAttenuation = 2.0;

@interface CBBeaconsMap()
@property CBBeacon *touchedBeacon;
@property CBBeacon *nearestBeacon;
@property BOOL moveBeacon;
@property CGPoint estimatedPosition;
@property NSMutableArray *previousEstimatedPositions;
@property NSMutableArray *previousEstimatedErrors;
@end

@implementation CBBeaconsMap

NSMutableArray *_beacons;

- (void)awakeFromNib {
    [super awakeFromNib];

    [self initData];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initData];
    }
    
    return self;
}

- (void)initData {
    _previousEstimatedPositions = [NSMutableArray array];
    _previousEstimatedErrors = [NSMutableArray array];
}

- (void)resetPreviousData {
    [self initData];
}

- (void)calculateAndSetEstimatedPosition:(CGPoint)lastEstimated {
    [_previousEstimatedPositions addObject:[NSValue valueWithCGPoint:lastEstimated]];
    
    if ([_previousEstimatedPositions count] > kAverageElements) {
        [_previousEstimatedPositions removeObjectAtIndex:0];
    }
    
    CGPoint total = CGPointZero;
    for (NSValue *value in _previousEstimatedPositions) {
        CGPoint point = [value CGPointValue];
        total.x += point.x;
        total.y += point.y;
    }
    
    CGPoint avg = CGPointMake(total.x / _previousEstimatedPositions.count, total.y / _previousEstimatedPositions.count);
    
    CGRect room = CGRectInset([self pixelRoomRect], 10, 10);
    CGPoint maxPoint = CGPointMake(MAX(room.origin.x, avg.x), MAX(room.origin.y, avg.y));
    _estimatedPosition = CGPointMake(MIN(maxPoint.x, room.origin.x + room.size.width), MIN(maxPoint.y, room.origin.y + room.size.height));
    
    // CALCULATE NEAREST NEIGHBOR
    _nearestBeacon = _beacons[0];
    for (CBBeacon *beacon in _beacons) {
//        float dx = beacon.position.x/[self pixelScale] - _estimatedPosition.y;
//        float dy = beacon.position.y/[self pixelScale] - _estimatedPosition.y;
//        float beaconToPoint = dx*dx + dy*dy;
//        
//        float ndx = _nearestBeacon.position.x/[self pixelScale] - _estimatedPosition.y;
//        float ndy = _nearestBeacon.position.y/[self pixelScale] - _estimatedPosition.y;
//        float nearestToPoint = ndx*ndx + ndy*ndy;
//        
//        if (beaconToPoint < nearestToPoint) {
        if (beacon.distance < _nearestBeacon.distance) {
//        if (beacon.rssi > _nearestBeacon.rssi) {
            _nearestBeacon = beacon;
        }
    }

}

- (float)calculateErrorUsingEstimatedPosition {
    float currentError = 0;
    for (CBBeacon *beacon in _beacons) {
        float dx = beacon.position.x - _estimatedPosition.x;
        float dy = beacon.position.y - _estimatedPosition.y;
        float beaconToEstimate = sqrt(dx*dx + dy*dy);
        float diff = beaconToEstimate - [self pixelDistanceFor:beacon];
        currentError = MAX(currentError, fabs(diff));
    }
    
    [_previousEstimatedErrors addObject:[NSNumber numberWithFloat:currentError]];
    
    if ([_previousEstimatedErrors count] > kAverageElements) {
        [_previousEstimatedErrors removeObjectAtIndex:0];
    }
    
    float total = 0;
    for (NSNumber *value in _previousEstimatedErrors) {
        float point = [value floatValue];
        total += point;
    }
    
    float avg = total/_previousEstimatedErrors.count;

    return avg;
}

- (void)calculateProbabilityPointsManual {
    CGPoint minErrorPoint;
    float minError = 1000.0f;
    
    for (float x = 0; x < _physicalSize.width; x = x + kGapDistance) {
        for (float y = 0; y < _physicalSize.height; y = y + kGapDistance) {
            float error = 0.0;
            for (CBBeacon *beacon in _beacons) {
                float dx = beacon.position.x/[self pixelScale] - x;
                float dy = beacon.position.y/[self pixelScale] - y;
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
    
    [self calculateAndSetEstimatedPosition:CGPointMake(minErrorPoint.x * [self pixelScale], minErrorPoint.y * [self pixelScale])];
    
    [_delegate beaconMap:self lastMeasuredPoints:_previousEstimatedPositions];
}

- (void)calculateProbabilityPointsLeastLibrary {
    [LocationManager determine:_beacons success:^(CGPoint location) {
        [self calculateAndSetEstimatedPosition:location];

        [_delegate beaconMap:self lastMeasuredPoints:_previousEstimatedPositions];

    } failure:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)calculateProbabilityPoints {
    if (_method == CBEstimationMethodHeuristic) {
        [self calculateProbabilityPointsManual];
    } else {
        [self calculateProbabilityPointsLeastLibrary];        
    }
}

- (NSMutableArray *)beacons {
    return _beacons;
}

- (void)setBeacons:(NSMutableArray *)beacons {
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
    
    // DRAW BEACONS AND ITS RANGE
    float beaconSize = 20;
    UIFont *font= [UIFont systemFontOfSize:11.0];
    for (CBBeacon *beacon in _beacons) {
        if (beacon.name) {
            CGPoint nameLocation;
            NSString *label = [NSString stringWithFormat:@"%@ (%.2fm)", beacon.name, beacon.distance];
            CGSize labelSize = [label sizeWithAttributes:@{NSFontAttributeName:font}];
            if (self.bounds.size.width - beacon.position.x <= beaconSize * 2) {
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
            } else {
                nameLocation.x = beacon.position.x + beaconSize/2 + 2;
                nameLocation.y = beacon.position.y - beaconSize/2;
            }
            
            [label drawAtPoint:nameLocation withAttributes:@{NSFontAttributeName:font}];
        }
        
        if (_drawMethod == CBDrawMethodNearestBeacon) {
            if (_nearestBeacon == beacon) {
                CGContextSetFillColorWithColor(ctx, [[UIColor greenColor] CGColor]);
            } else if (_moveBeacon && _touchedBeacon == beacon) {
                CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
            } else {
                CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
            }   
        } else {
            if (beacon.proximity == CLProximityFar) {
                CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
            } else if (beacon.proximity == CLProximityImmediate) {
                CGContextSetFillColorWithColor(ctx, [[UIColor greenColor] CGColor]);
            } else if (beacon.proximity == CLProximityNear) {
                CGContextSetFillColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
            } else {
                CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
            }
        }
        
        CGContextFillRect(ctx, CGRectMake(beacon.position.x - beaconSize/2, beacon.position.y - beaconSize/2, beaconSize, beaconSize));
        
        CGContextSetLineWidth(ctx,1);
        CGContextSetRGBStrokeColor(ctx,0.8,0.8,0.8,1.0);
        
        CGContextAddArc(ctx, beacon.position.x, beacon.position.y, [self pixelDistanceFor:beacon], 0.0, M_PI*2, YES);
        CGContextStrokePath(ctx);
    }
    
    // ROOM SIZE
    CGContextSetAlpha(ctx, 0.5);
    NSString *roomWidth = [NSString stringWithFormat:@"room size: %.2fm x %.2fm", _physicalSize.width, _physicalSize.height];
    [roomWidth drawAtPoint:CGPointMake(10, 10) withAttributes:@{NSFontAttributeName:font}];
    
    // ESTIMATED POSITION
    if (_drawMethod == CBDrawMethodEstimatedPosition) {
        float deviceSize = 15;
        float error = [self calculateErrorUsingEstimatedPosition] / [self pixelScale];
        NSLog(@"estimated error: %f", error);
        if (_estimatedPosition.x && _estimatedPosition.y) {
            UIColor *color;
            if (error <= 2) {
                color = [UIColor greenColor];
            } else if (error <= 5) {
                color = [UIColor blueColor];
            } else {
                color = [UIColor redColor];
            }
            CGContextSetFillColorWithColor(ctx, [color CGColor]);
            
            CGContextFillEllipseInRect(ctx, CGRectMake(_estimatedPosition.x - deviceSize/2, _estimatedPosition.y - deviceSize/2, deviceSize, deviceSize));
        }
    }
    
    // ROOM BORDERS
    CGContextSetLineWidth(ctx, 6);
    CGContextStrokeRect(ctx, CGRectInset([self pixelRoomRect], 3, 3));
}

- (CGRect)pixelRoomRect {
    if ([self pixelScaleX] > [self pixelScaleY]) {
        return CGRectMake((self.bounds.size.width - _physicalSize.width * [self pixelScaleY])/2, 0, _physicalSize.width * [self pixelScaleY], _physicalSize.height * [self pixelScaleY]);
    } else {
        return CGRectMake(0, (self.bounds.size.height - _physicalSize.height * [self pixelScaleX])/2, _physicalSize.width * [self pixelScaleX], _physicalSize.height * [self pixelScaleX]);
    }
}

- (float)pixelScaleX {
    return self.bounds.size.width/_physicalSize.width;
}

- (float)pixelScaleY {
    return self.bounds.size.height/_physicalSize.height;
}

- (float)pixelScale {
    return [self pixelScaleX] > [self pixelScaleY] ? [self pixelScaleY] : [self pixelScaleX];
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
    
    _touchedBeacon = nearest;
}

- (void)processTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    
    if (_moveBeacon && _touchedBeacon) {
        _touchedBeacon.position = CGPointMake(_touchedBeacon.position.x - (prevLocation.x - location.x), _touchedBeacon.position.y - (prevLocation.y - location.y));
    } else { // move distance
        _touchedBeacon.distance += (prevLocation.y - location.y) / [self pixelScale];
    }
    
    [self calculateProbabilityPoints];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self processTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchedBeacon = nil;
    _moveBeacon = NO;
    
    [_delegate beaconMap:self beaconsPropertiesChanged:_beacons];

    [self processTouches:touches withEvent:event];
}

@end
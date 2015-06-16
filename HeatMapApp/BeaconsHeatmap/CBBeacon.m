//
//  CBBeacon.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/20/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBBeacon.h"

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
        _proximity = [[decoder decodeObjectForKey:@"proximity"] floatValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    if (_name) {
        [encoder encodeObject:_name forKey:@"name"];
    }
    [encoder encodeObject:[NSValue valueWithCGPoint:_position] forKey:@"position"];
    [encoder encodeObject:[NSNumber numberWithFloat:_distance] forKey:@"distance"];
    [encoder encodeObject:[NSNumber numberWithInteger:_proximity] forKey:@"proximity"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%.1f, %1.f): %.2fm", _name, _position.x, _position.y, _distance];
}

@end

@implementation CBSignal

@end

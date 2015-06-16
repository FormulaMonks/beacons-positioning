//
//  CBBeaconsHelper.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/20/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBBeaconsHelper.h"
#import "CBBeacon.h"

const float kRoomWidth = 3.5;
const float kRoomHeight = 5.5;
const BOOL kLogValues = YES;
const int kMaxLogValues = 3000;

static NSString *kBeaconsFilename = @"beacons.plist";

@interface CBBeaconsHelper()
@property NSMutableArray *recordingLog;
@property NSDate *startRecordingTime;

@property NSTimer *playLogTimer;
@property NSTimeInterval playLogTime;
@end

@implementation CBBeaconsHelper

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _recordingLog = [NSMutableArray array];
    }
    
    return self;
}

- (CGSize)roomSize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *width = [defaults objectForKey:@"room_width"];
    NSNumber *height = [defaults objectForKey:@"room_height"];
    
    if (!width && !height) {
        [defaults setObject:[NSNumber numberWithFloat:kRoomWidth] forKey:@"room_width"];
        [defaults setObject:[NSNumber numberWithFloat:kRoomHeight] forKey:@"room_height"];
        [defaults synchronize];
    }
    
    width = [defaults objectForKey:@"room_width"];
    height = [defaults objectForKey:@"room_height"];
    
    NSAssert(width != 0, @"room width can't be zero");
    NSAssert(height != 0, @"room height can't be zero");
    
    return CGSizeMake([width floatValue], [height floatValue]);
}

- (void)initLogTimers {
    [_recordingLog removeAllObjects];
    _startRecordingTime = [NSDate date];
}

- (void)saveLog {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSString *logFile = [NSString stringWithFormat:@"log-%@.plist", [[NSDate date] description]];
    [_recordingLog writeToFile:[docDirectory stringByAppendingPathComponent:logFile] atomically:YES];
}

- (void)appendToLog:(NSArray *)signals {
    if (kLogValues && ![_playLogTimer isValid] && _recordingLog.count < kMaxLogValues) {
        for (CBSignal *signal in signals) {
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_startRecordingTime];
            [_recordingLog addObject:@{@"minor": signal.minor,
                                       @"rssi": signal.rssi,
                                       @"distance": signal.distance,
                                       @"proximity": [NSNumber numberWithInteger:signal.proximity],
                                       @"time": [NSNumber numberWithDouble:diff]}];
        }
    }
}

- (NSMutableArray *)loadBeacons {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSArray *savedBeacons = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename]];
    
    NSMutableArray *beacons = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int minorStart = [[defaults objectForKey:@"minor"] intValue];
    for (int i = 0; i < [[defaults objectForKey:@"beacons"] intValue]; i++) {
        CBBeacon *beacon = [[CBBeacon alloc] initWithX:20 + i * 20 y:20 + i * 25 distance:2.0];
        beacon.name = [NSString stringWithFormat:@"%d", minorStart + i];
        beacon.minor = [NSNumber numberWithInt:minorStart + i];
        [beacons addObject:beacon];
    }
    
    NSMutableArray *retBeacons = nil;
    if (savedBeacons.count != beacons.count) {
        if (savedBeacons) {
            retBeacons = [savedBeacons mutableCopy];
        } else {
            retBeacons = [NSMutableArray array];
        }
        
        if (savedBeacons.count < beacons.count) {
            for (NSUInteger i = savedBeacons.count; i < beacons.count; i++) {
                CBBeacon *beacon = beacons[i];
                [retBeacons addObject:beacon];
            }
        } else {
            for (NSUInteger i = savedBeacons.count - 1; i >= beacons.count; i--) {
                CBBeacon *beacon = savedBeacons[i];
                [retBeacons removeObject:beacon];
            }
        }
        
        [self saveBeacons:retBeacons];
    } else {
        retBeacons = [savedBeacons mutableCopy];
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    int i = 0;
    for (CBBeacon *beacon in retBeacons) {
        if (!beacon.minor) { // backward compatibility, remove previous saved beacons without minor
            beacon.minor = [NSNumber numberWithInt:minorStart + i];
            i++;
        }
    }
    [retBeacons removeObjectsInArray:toRemove];
    
    return retBeacons;
}

- (void)saveBeacons:(NSArray *)beacons {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:beacons];
    [data writeToFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename] atomically:YES];
}

- (void)deleteBeacons {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[docDirectory stringByAppendingPathComponent:kBeaconsFilename] error:nil];
}

- (void)playLog:(NSArray *)signals {
    [_playLogTimer invalidate];
    _playLogTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(logTick:) userInfo:signals repeats:YES];
    [_playLogTimer fire];
}

- (void)stopPlayingLog {
    [_playLogTimer invalidate];
    _playLogTime = 0;
}

- (void)logTick:(NSTimer *)timer {
    _playLogTime += timer.timeInterval;
    
    NSMutableArray *logs = (NSMutableArray *)timer.userInfo;
    
    if (logs.count == 0) {
        [timer invalidate];
        _playLogTime = 0;
        [_delegate helperDidFinishLog:self];
        
        return;
    }
    
//    NSLog(@"%d %f", (int)logs.count, _playLogTime);
    
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    NSMutableArray *currentBeacons = [NSMutableArray array];
    [logs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *item = (NSDictionary *)obj;
        
        if ([item[@"time"] doubleValue] <= _playLogTime) {
            if ([item[@"distance"] floatValue] > 0) {
                [toRemove addIndex:idx];
                
                CBSignal *signal = [CBSignal new];
                signal.minor = item[@"minor"];
                signal.distance = item[@"distance"];
                signal.proximity = [item[@"proximity"] intValue];
                [currentBeacons addObject:signal];
            }
        } else {
            *stop = YES;
        }
        
        if (currentBeacons.count > 0) {
            [_delegate helper:self didReadBeaconsFromLog:currentBeacons];
        }
    }];
    
    [logs removeObjectsAtIndexes:toRemove];
}

@end

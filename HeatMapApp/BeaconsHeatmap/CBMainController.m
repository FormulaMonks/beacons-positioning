//
//  ViewController.m
//  BeaconsHeatmap
//
//  Created by Eleonora on 22/1/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBMainController.h"
#import "LFHeatMap.h"
#import "CBBeaconsMap.h"
#import "CBBeaconsSimulator.h"
#import "CBSettingsViewController.h"
#import "CBBeaconsRanger.h"

const int kMinorStartValue = 6131;

const float kRoomWidth = 3.5;
const float kRoomHeight = 5.5;

static NSString *kBeaconsFilename = @"beacons.plist";

@interface CBMainController () <CBBeaconsMapDelegate, CBBeaconsSimulatorDelegate, CBBeaconsRangerDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@property CBBeaconsSimulator *simulator;
@property CBBeaconsRanger *ranger;

@property BOOL heatmap;

@end

@implementation CBMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _simulator = [CBBeaconsSimulator new];
    _simulator.delegate = self;
    
    _ranger = [CBBeaconsRanger new];
    _ranger.delegate = self;
    
    _beaconsView.physicalSize = [self roomSize];
    _beaconsView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CBEstimationMethod method = [[defaults objectForKey:@"estimation"] integerValue];
    
    _beaconsView.method = method;
    
    _heatmap = [[defaults objectForKey:@"heatmap"] boolValue];
    _imageView.alpha = _heatmap ? 1.0 : 0.0;
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

- (IBAction)changeSimulation:(UIBarButtonItem *)sender {
    if ([sender.title hasPrefix:@"Start"]) {
        [sender setTitle:@"Stop Simulation"];
        [_simulator simulateBeacons:_beaconsView.beacons noise:0.05];
    } else {
        [sender setTitle:@"Start Simulation"];
        [_simulator stopSimulation];
    }
}

- (IBAction)changeRanging:(UIBarButtonItem *)sender {
    if ([sender.title hasPrefix:@"Start"]) {
        [sender setTitle:@"Stop Ranging"];
        [_ranger startRanging];
    } else {
        [sender setTitle:@"Start Ranging"];
        [_ranger stopRanging];
    }
}

- (IBAction)dismissViewController:(UIStoryboardSegue *)segue {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    CBSettingsViewController *settingsVC = (CBSettingsViewController *)segue.sourceViewController;
    [settingsVC save];
    
    // update room size
    _beaconsView.physicalSize = [self roomSize];
    [_beaconsView updateBeacons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];

    NSArray *savedBeacons = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename]];
    
    NSMutableArray *beacons = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int minorStart = kMinorStartValue;
    for (int i = 0; i < [[defaults objectForKey:@"beacons"] intValue]; i++) {
        CBBeacon *beacon = [[CBBeacon alloc] initWithX:20 + i * 20 y:20 + i * 25 distance:2.0];
        beacon.name = [NSString stringWithFormat:@"%d", minorStart + i];
        [beacons addObject:beacon];
    }
    
    if (savedBeacons.count != beacons.count) {
        if (savedBeacons) {
            _beaconsView.beacons = [savedBeacons mutableCopy];
        } else {
            _beaconsView.beacons = [NSMutableArray array];
        }
        
        if (savedBeacons.count < beacons.count) {
            for (int i = savedBeacons.count; i < beacons.count; i++) {
                CBBeacon *beacon = beacons[i];
                [_beaconsView.beacons addObject:beacon];
                [_beaconsView updateBeacons];
            }
        } else {
            for (int i = savedBeacons.count - 1; i >= beacons.count; i--) {
                CBBeacon *beacon = savedBeacons[i];
                [_beaconsView.beacons removeObject:beacon];
                [_beaconsView updateBeacons];
            }
        }
        
        [self saveBeacons:_beaconsView.beacons];
    } else {
        _beaconsView.beacons = [savedBeacons mutableCopy];
    }
}

- (void)saveBeacons:(NSArray *)beacons {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:beacons];
    [data writeToFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename] atomically:YES];
}

// Delegates

- (void)beaconsRanger:(CBBeaconsRanger *)ranger didRangeBeacons:(NSArray *)beacons {
    for (CBBeacon *beaconView in _beaconsView.beacons) {
        for (CLBeacon *beacon in beacons) {
            if (beaconView.name == nil || [beaconView.name isEqualToString:[beacon.minor stringValue]]) { // in case it's empty assign the first empty
                beaconView.name = [beacon.minor stringValue];
                beaconView.distance = (float)beacon.accuracy;
            }
        }

        [_beaconsView updateBeacons];
    }
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap probabilityPointsUpdated:(NSArray *)points {
    if (_heatmap) {
        NSMutableArray *weights = [NSMutableArray arrayWithCapacity:points.count];
        for (int i = 0; i < points.count; i++) {
            [weights addObject:[NSNumber numberWithFloat:10.0]];
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.6 points:points weights:weights];
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageView.image = map;
            });
        });
    }
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap beaconsPropertiesChanged:(NSArray *)beacons {
    [self saveBeacons:beacons];
}

-(void)beaconSimulatorDidChange:(CBBeaconsSimulator *)simulator {
    [_beaconsView updateBeacons];
}

@end

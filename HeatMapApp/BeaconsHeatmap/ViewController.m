//
//  ViewController.m
//  BeaconsHeatmap
//
//  Created by Eleonora on 22/1/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "ViewController.h"
#import "LFHeatMap.h"
#import "CBBeaconsMap.h"
#import "CBBeaconsSimulator.h"
#import "SIOSocket.h"

static NSString *kBeaconsFilename = @"beacons.plist";

@interface ViewController () <CBBeaconsMapDelegate, CBBeaconsSimulatorDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@property CBBeaconsSimulator *simulator;
@property SIOSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _simulator = [CBBeaconsSimulator new];
    _simulator.delegate = self;
    
    _beaconsView.physicalSize = CGSizeMake(3.15, 4.7);
    _beaconsView.delegate = self;
    
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket) {
        _socket = socket;
        _socket.onConnect = ^(void) {
            NSLog(@"socket connected.");
        };
        [_socket on:@"update" callback:^(NSArray *args) {
            NSArray *devices = args[0];
            for (int i = 0; i < devices.count; i++) {
                NSDictionary *item = devices[i];
                CBBeacon *beacon = _beaconsView.beacons[i];
                
                beacon.name = item[@"name"];
                beacon.distance = [item[@"distance"] floatValue];
                NSLog(@"distance to %@: %f", beacon.name, beacon.distance);
                
                [_beaconsView updateBeacons];
            }
        }];
    }];
}

- (IBAction)changeSimulation:(UIButton *)sender {
    if ([sender.titleLabel.text hasPrefix:@"Start"]) {
        [sender setTitle:@"Stop Simulation" forState:UIControlStateNormal];
        [_simulator simulateBeacons:_beaconsView.beacons noise:0.05];
    } else {
        [sender setTitle:@"Start Simulation" forState:UIControlStateNormal];
        [_simulator stopSimulation];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];

    NSArray *savedBeacons = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename]];
    if (savedBeacons) {
        _beaconsView.beacons = savedBeacons;
    } else {
        CBBeacon *b1 = [[CBBeacon alloc] initWithX:20 y:_beaconsView.bounds.size.height*0.5 distance:2.4];
        CBBeacon *b2 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:_beaconsView.bounds.size.height - 20 distance:2.0];
        CBBeacon *b3 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width - 20 y:_beaconsView.bounds.size.height/2 distance:2.3];
        
        _beaconsView.beacons = @[b1, b2, b3];
    }
}

// Delegates

- (void)beaconMap:(CBBeaconsMap *)beaconMap probabilityPointsUpdated:(NSArray *)points {
    NSMutableArray *weights = [NSMutableArray arrayWithCapacity:points.count];
    for (int i = 0; i < points.count; i++) {
        [weights addObject:[NSNumber numberWithFloat:10.0]];
    }
    UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.6 points:points weights:weights];
    _imageView.image = map;
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap beaconsPropertiesChanged:(NSArray *)beacons {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:beacons];
    [data writeToFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename] atomically:YES];
}

-(void)beaconSimulatorDidChange:(CBBeaconsSimulator *)simulator {
    [_beaconsView updateBeacons];
}

@end

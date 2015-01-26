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

@interface ViewController () <CBBeaconsMapDelegate, CBBeaconsSimulatorDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@property CBBeaconsSimulator *simulator;
@property SRWebSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _simulator = [CBBeaconsSimulator new];
    _simulator.delegate = self;
    
    _beaconsView.delegate = self;    
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
    
    CBBeacon *b1 = [[CBBeacon alloc] initWithX:0 y:_beaconsView.bounds.size.height*0.5 distance:_beaconsView.bounds.size.width * 0.9];
    CBBeacon *b2 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:_beaconsView.bounds.size.height distance:_beaconsView.bounds.size.height * 0.6];
    CBBeacon *b3 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width y:_beaconsView.bounds.size.height/2 distance:_beaconsView.bounds.size.height * 0.5];
    CBBeacon *b4 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:0 distance:_beaconsView.bounds.size.height * 0.6];
    
    _beaconsView.beacons = @[b1, b2, b3, b4];
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

@end

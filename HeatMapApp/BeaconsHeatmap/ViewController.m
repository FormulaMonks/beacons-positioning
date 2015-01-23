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

@interface ViewController () <CBBeaconsMapDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _beaconsView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CBBeacon *b1 = [[CBBeacon alloc] initWithX:0 y:40 distance:200];
    CBBeacon *b2 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width y:_beaconsView.bounds.size.height/2 distance:150];
    CBBeacon *b3 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:_beaconsView.bounds.size.height distance:320];
    _beaconsView.beacons = @[b1, b2, b3];
    [_beaconsView setNeedsDisplay];
}

- (void)probabilityPointsUpdated:(NSArray *)points {
    NSMutableArray *weights = [NSMutableArray arrayWithCapacity:points.count];
    for (int i = 0; i < points.count; i++) {
        [weights addObject:[NSNumber numberWithFloat:10.0]];
    }
    UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.5 points:points weights:weights];
    _imageView.image = map;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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

@interface ViewController ()

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@property NSMutableArray *points;
@property NSMutableArray *weights;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _points = [NSMutableArray array];
    _weights = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CBBeacon *b1 = [[CBBeacon alloc] initWithX:0 y:40 distance:200];
    CBBeacon *b2 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width y:_beaconsView.bounds.size.height/2 distance:150];
    CBBeacon *b3 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:_beaconsView.bounds.size.height distance:320];
    _beaconsView.beacons = @[b1, b2, b3];
    [_beaconsView setNeedsDisplay];
    
    NSValue *p1 = [NSValue valueWithCGPoint:CGPointMake(100, 100)];
    NSValue *p2 = [NSValue valueWithCGPoint:CGPointMake(110, 100)];
    NSValue *p3 = [NSValue valueWithCGPoint:CGPointMake(120, 120)];
    NSValue *p4 = [NSValue valueWithCGPoint:CGPointMake(121, 140)];
    NSValue *p5 = [NSValue valueWithCGPoint:CGPointMake(135, 150)];
    _points = [@[p1, p2, p3, p4, p5] mutableCopy];
    _weights = [@[@10.2, @12.1, @25.5, @16.0, @5.2] mutableCopy];
    
    UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.5 points:_points weights:_weights];
    _imageView.image = map;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

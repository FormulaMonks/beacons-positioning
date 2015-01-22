//
//  ViewController.m
//  BeaconsHeatmap
//
//  Created by Eleonora on 22/1/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "ViewController.h"
#import "LFHeatMap.h"

@interface ViewController ()

@property IBOutlet UIImageView *imageView;

@property NSMutableArray *points;
@property NSMutableArray *weights;

@property float dirX;
@property float dirY;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _points = [NSMutableArray array];
    _weights = [NSMutableArray array];
    
    _dirX = 1.0;
    _dirY = 1.0;
    
    [self performSelector:@selector(movePoints) withObject:nil afterDelay:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSValue *p1 = [NSValue valueWithCGPoint:CGPointMake(100, 100)];
    NSValue *p2 = [NSValue valueWithCGPoint:CGPointMake(110, 100)];
    NSValue *p3 = [NSValue valueWithCGPoint:CGPointMake(120, 120)];
    NSValue *p4 = [NSValue valueWithCGPoint:CGPointMake(121, 140)];
    NSValue *p5 = [NSValue valueWithCGPoint:CGPointMake(135, 150)];
    _points = [@[p1, p2, p3, p4, p5] mutableCopy];
    _weights = [@[@10.2, @12.1, @25.5, @16.0, @5.2] mutableCopy];
    
    UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.5 points:_points weights:_weights];
    _imageView.image = map;
    
    [self performSelector:@selector(movePoints) withObject:nil afterDelay:0.1];
}

- (void)movePoints {
    float changeY = NO;
    float changeX = NO;
    for (int i = 0; i < [_points count]; i++) {
        NSValue *value = _points[i];
        CGPoint point = [value CGPointValue];
        float maxY = _imageView.bounds.size.height;
        float maxX = _imageView.bounds.size.width;
        if (point.y >= maxY || point.y <= 0) {
            changeY = YES;
            point.y = point.y >= maxY ? maxY - 1 : 1;
        } else {
            point.y += 2 * _dirY;
        }

        if (point.x >= maxX || point.x <= 0) {
            changeX = YES;
            point.x = point.x >= maxX ? maxX - 1 : 1;
        } else {
            point.x += 2 * _dirX * i/5;
        }

        _points[i] = [NSValue valueWithCGPoint:point];
    }
    
    if (changeY) {
        _dirY *= -1;
    }

    if (changeX) {
        _dirX *= -1;
    }

    UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.5 points:_points weights:_weights];
    _imageView.image = map;
    
    [self performSelector:@selector(movePoints) withObject:nil afterDelay:0.03];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

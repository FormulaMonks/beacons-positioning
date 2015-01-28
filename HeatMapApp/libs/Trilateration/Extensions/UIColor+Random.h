//
//  UIColor+Random.h
//  iBeacon-Geo-Demo
//
//  Created by Nemanja Joksovic on 4/6/14.
//  Copyright (c) 2014 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Random)

+ (UIColor *)randomColor:(CGFloat)alpha;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

@end

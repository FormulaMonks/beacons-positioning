//
//  UIColor+Random.m
//  iBeacon-Geo-Demo
//
//  Created by Nemanja Joksovic on 4/6/14.
//  Copyright (c) 2014 R/GA. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor:(CGFloat)alpha
{
    CGFloat red = arc4random() % 255 / 255.0;
    CGFloat green = arc4random() % 255 / 255.0;
    CGFloat blue = arc4random() % 255 / 255.0;

    return [UIColor colorWithRed:red
                           green:green
                            blue:blue
                           alpha:alpha];
}

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;

    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    }
    
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    }
    
    return nil;
}
@end

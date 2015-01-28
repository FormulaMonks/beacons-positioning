//
//  UIView+Additions.h
//  iBeacon-Geo-Demo
//
//  Created by Nemanja Joksovic on 4/6/14.
//  Copyright (c) 2014 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (CGPoint)position;
- (void)setPosition:(CGPoint)position;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)left;
- (void)setLeft:(CGFloat)x;

- (CGFloat)top;
- (void)setTop:(CGFloat)y;

- (CGFloat)right;
- (void)setRight:(CGFloat)right;

- (CGFloat)bottom;
- (void)setBottom:(CGFloat)bottom;

- (CGSize)size;
- (void)setSize:(CGSize)size;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

@end

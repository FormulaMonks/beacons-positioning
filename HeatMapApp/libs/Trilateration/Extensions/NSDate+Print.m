//
//  NSDate+Print.m
//  iBeacon-Geo-Demo
//
//  Created by Nemanja Joksovic on 4/6/14.
//  Copyright (c) 2014 R/GA. All rights reserved.
//

#import "NSDate+Print.h"

@implementation NSDate (Print)

- (NSString *)asString
{
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterMediumStyle];
}

@end

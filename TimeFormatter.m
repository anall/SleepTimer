//
//  TimeFormatter.m
//  SleepTimer
//
//  Created by Andrea Nall on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TimeFormatter.h"

@implementation TimeFormatter

+(TimeFormatter *)formatter {
    return [[[TimeFormatter alloc] init] autorelease];
}

-(NSString *)stringForObjectValue:(id)anObject {
    if ([anObject respondsToSelector:@selector(hour)] && [anObject respondsToSelector:@selector(minute)]) {
        return [NSString stringWithFormat:@"%i:%02i",[anObject hour],[anObject minute]];
    } else {
        return @"";
    }
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    int temp;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSDateComponents *time = [[[NSDateComponents alloc] init] autorelease];
    
    if (![scanner scanInt:&temp]) {
        return NO;
    } else if (temp < 0 || temp >= 24) {
        return NO;
    }
    time.hour = temp;
    
    [scanner scanString:@":" intoString:nil];
    
    if (![scanner scanInt:&temp]) {
        return NO;
    } else if (temp < 0 || temp >= 60) {
        return NO;
    }
    time.minute = temp;
    
    *anObject = time;
    return YES;
}

@end

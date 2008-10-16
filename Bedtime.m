//
//  Bedtime.m
//  SleepTimer
//
//  Created by Andrea Nall on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bedtime.h"


@implementation Bedtime
@synthesize enabled, time, nagText;

- (void) dealloc {
    [time release];
    [nagText release];
    [super dealloc];
}

@end

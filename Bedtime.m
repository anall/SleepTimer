//
//  Bedtime.m
//  SleepTimer
//
//  Created by Andrea Nall on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bedtime.h"


@implementation Bedtime
@synthesize enabled, time, nagText, dialogText;

-(id)init {
    self = [super init];
    if (self != nil) {
        enabled = YES;
        self.nagText = @"";
        self.dialogText = @"";
        self.time = nil;
    }
    return self;
}

-(void)dealloc {
    [time release];
    [nagText release];
    [dialogText release];
    [super dealloc];
}

@end

//
//  alarmtime.h
//  SleepTimer
//
//  Created by Andrea Nall on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface alarmtime : NSObject {
    BOOL enabled;
    NSDateComponents *time;
    NSString *nagText;
    NSString *dialogText;
}
@property BOOL enabled;
@property (retain) NSDateComponents *time;
@property (retain) NSString *nagText;
@property (retain) NSString *dialogText;


@end

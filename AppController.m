//
//  AppController.m
//  SleepTimer
//
//  Created by Andrea Nall on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "alarmtime.h"
#import "TimeFormatter.h"

@interface AppController (Private)
-(alarmtime*)getNearestalarmtime:(NSDate **)date;
-(alarmtime*)getNearestalarmtime:(NSDate **)date after:(NSDateComponents *)components;
-(void)popWindowToFrontAwayFromCursor:(NSWindow *)theWindow;


-(void)setupTimer;
-(void)enqueueNext;

-(void)doWarning:(NSTimer *)t;
-(void)doNag:(NSTimer *)t;
-(void)doTick:(NSTimer *)t;

-(void)setupKeepFrontFor:(NSWindow *)window;
-(void)keepFrontTick:(NSTimer *)t;
-(void)abortKeepFront;
@end

@implementation AppController
@synthesize alarmtimes, warnTimes, nagTimes;

@synthesize mainWindow;
@synthesize prefsTimeColumn;
@synthesize alarmtimeArrayController;
@synthesize warnTimeArrayController;

@synthesize warningWindow;
@synthesize warningWhich;
@synthesize warningReason;

@synthesize nagWindow;
@synthesize nagWhich;
@synthesize nagReason;

@synthesize countDownText,countDownReason;

@synthesize skipPast;
@synthesize currentalarmtime,currentalarmtimeReason,currentalarmtimeDialogReason;

@synthesize warningDates;
@synthesize pendingNags;

@synthesize timer,tickTimer;

@synthesize keepFrontTimer, keepFrontWindow, putFronts;

#pragma mark Setup
- (id)init {
    self = [super init];
    if (self != nil) {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        [self loadSettings];
        
        inWarning = NO;
        skipPast = nil;
        currentalarmtime = nil;
    }
    return self;
}
- (void)awakeFromNib {
    [[prefsTimeColumn dataCell] setFormatter:[TimeFormatter formatter]];
    [self setupTimer];
}
- (void)dealloc {
    [gregorian release];
    
    [alarmtimes release];
    [warnTimes release];
    [nagTimes release];
    
    [mainWindow release];
    [prefsTimeColumn release];
    [alarmtimeArrayController release];
    [warnTimeArrayController release];
    
    [warningWindow release];
    [warningWhich release];
    [warningReason release];
    
    [nagWindow release];
    [nagWhich release];
    [nagReason release];
    
    [countDownText release];
    [countDownReason release];
    
    [skipPast release];
    [currentalarmtime release];
    [currentalarmtimeReason release];
    [currentalarmtimeDialogReason release];
    
    [warningDates release];
    [pendingNags release];
    
    [timer release];
    [tickTimer release];
    
    [keepFrontTimer release];
    [keepFrontWindow release];
    
    [super dealloc];
}

#pragma mark Delegate Stuff
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self saveSettings];
}
- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    if (!inWarning)
        [mainWindow makeKeyAndOrderFront:self];
    inWarning = NO;
}

#pragma mark Actions
-(IBAction)sortalarmtimes:(id)sender {
    [alarmtimes sortUsingFunction:sortalarmtimes context:nil];
    [self didChangeValueForKey:@"alarmtimes"];
    [alarmtimeArrayController rearrangeObjects];
}
-(IBAction)sortWarnTimes:(id)sender {
    [warnTimes sortUsingFunction:sortWarnTimes context:nil];
    [self didChangeValueForKey:@"warnTimes"];
    [warnTimeArrayController rearrangeObjects];
}
-(IBAction)resetalarmtime:(id)sender {
}
-(IBAction)dismissWindow:(id)sender {
    NSWindow *w = keepFrontWindow;
    [self abortKeepFront];
    [w orderOut:sender];
}
#pragma mark Test Actions
-(IBAction)testWarning:(id)sender {
    [self doWarning:nil];
}
#pragma mark Settings
-(void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.alarmtimes = [NSMutableArray array];
    self.warnTimes = [NSMutableArray array];
    self.nagTimes = [NSMutableArray array];
    
    NSArray *_alarmtimes = [defaults arrayForKey:@"alarmtimes"];
    for (NSDictionary *_alarmtime in _alarmtimes) {
        alarmtime *alarmtime = [[[alarmtime alloc] init] autorelease];
        alarmtime.enabled = [[_alarmtime valueForKey:@"enabled"] boolValue];
        alarmtime.time = [[[NSDateComponents alloc] init] autorelease];
        alarmtime.time.hour = [[_alarmtime valueForKey:@"hour"] intValue];
        alarmtime.time.minute = [[_alarmtime valueForKey:@"minute"] intValue];
        alarmtime.nagText = [_alarmtime valueForKey:@"nagText"];
        if (alarmtime.nagText == nil) alarmtime.nagText = @"";
        alarmtime.dialogText = [_alarmtime valueForKey:@"dialogText"];
        if (alarmtime.dialogText == nil) alarmtime.dialogText = alarmtime.nagText;
        [alarmtimes addObject:alarmtime];
    }
    
    NSArray *_warnTimes = [defaults arrayForKey:@"warnTimes"];
    for (NSNumber *_time in _warnTimes) {
        [warnTimes addObject:[NSDictionary dictionaryWithObject:_time forKey:@"minutes"]];
    }
    
    NSArray *_nagTimes = [defaults arrayForKey:@"nagTimes"];
    for (NSNumber *_time in _nagTimes) {
        [nagTimes addObject:[NSDictionary dictionaryWithObject:_time forKey:@"minutes"]];
    }
}
-(void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *array;
    
    [self sortalarmtimes:nil];
    [self sortWarnTimes:nil];
    
    array = [NSMutableArray array];
    for (alarmtime *alarmtime in alarmtimes) {
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:alarmtime.enabled],@"enabled",
                          [NSNumber numberWithInt:alarmtime.time.hour],@"hour",
                          [NSNumber numberWithInt:alarmtime.time.minute],@"minute",
                          alarmtime.nagText,@"nagText",
                          alarmtime.dialogText,@"dialogText",nil]];
    }
    [defaults setObject:array forKey:@"alarmtimes"];
    
    array = [NSMutableArray array];
    for (NSDictionary *dict in warnTimes)
        [array addObject:[dict objectForKey:@"minutes"]];
    [defaults setObject:array forKey:@"warnTimes"];
    
    array = [NSMutableArray array];
    for (NSDictionary *dict in nagTimes)
        [array addObject:[dict objectForKey:@"minutes"]];
    [defaults setObject:array forKey:@"nagTimes"];
}

#pragma mark Private
-(alarmtime*)getNearestalarmtime:(NSDate **)_date {
    // lets make SURE we're sorted.
    [self sortalarmtimes:nil];
    [self sortWarnTimes:nil];
    
    // No alarmtimes, no nearest one
    if ([alarmtimes count] == 0)
        return nil;
    
    unsigned int unitFlags;
    NSDate *currentDate = [NSDate date];
    alarmtime *alarmtime;
    
    // Check if we need to skip
    if (skipPast != nil) {
        currentDate = skipPast;
    }
    unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:currentDate];
    
    self.skipPast = nil;
    
    // Lets see if we can find something today
    // The first one we find in the future is nearest.
    alarmtime = [self getNearestalarmtime:_date after:components];
    
    if (alarmtime != nil)
        return alarmtime;
    
    // Okay, there is nothing for today, so get the first enabled one for tomorrow.
    NSDateComponents *addComponents = [[NSDateComponents alloc] init];
    addComponents.day = 1;
    
    components = [gregorian components:unitFlags fromDate:[gregorian dateByAddingComponents:addComponents toDate:currentDate options:0]];
    components.hour = 0;
    components.minute = -1;
    
    [addComponents release];

    alarmtime = [self getNearestalarmtime:_date after:components];
    
    if (alarmtime != nil)
        return alarmtime;

    // Oops, we found nothing.
    *_date = nil;
    return nil;
}
-(alarmtime*)getNearestalarmtime:(NSDate **)_date after:(NSDateComponents *)components {
    alarmtime *aTime;
    NSDateComponents *alarmtimeTime = nil;
    alarmtime *alarmtime;
    
    *_date = nil;
    for (aTime in alarmtimes) {
        NSDateComponents *time = aTime.time;
        if (!aTime.enabled) {
        } else if (time.hour > components.hour) {
            alarmtimeTime = time;
            alarmtime = aTime;
            break;
        } else if (time.hour == components.hour && time.minute > components.minute) {
            alarmtimeTime = time;
            alarmtime = aTime;
            break;
        }
    }

    if (alarmtimeTime != nil) {
        components.hour = alarmtimeTime.hour;
        components.minute = alarmtimeTime.minute;
        components.second = 0;
        
        *_date = [gregorian dateFromComponents:components];
        
        return alarmtime;
    }
    
    return nil;
}
-(void)popWindowToFrontAwayFromCursor:(NSWindow *)theWindow {
    inWarning = YES;
    NSPoint loc = [NSEvent mouseLocation];
    NSPoint windowPoint;
    NSSize windowSize = [theWindow frame].size;
    
    NSSize screenSize = [[NSScreen mainScreen] frame].size;
    
    int xOffset = (rand() % 75) + 75;
    int yOffset = (rand() % 75) + 75;
    int dir;
    
    // Figure out x direction.
    dir = rand() % 2;
    if (dir == 1)
        xOffset = -xOffset;
    windowPoint.x = loc.x + xOffset;
    if (windowPoint.x < 0)
        windowPoint.x = loc.x - xOffset;
    if ((windowPoint.x + windowSize.width) > screenSize.width)
        windowPoint.x = loc.x - xOffset;
    
    // Figure out y direction.
    dir = rand() % 2;
    if (dir == 1)
        yOffset = -yOffset;
    windowPoint.y = loc.y + yOffset;
    if ((windowPoint.y - windowSize.height) < 0)
        windowPoint.y = loc.y - xOffset;
    if ((windowPoint.y + windowSize.height) > screenSize.height)
        windowPoint.y = loc.y - xOffset;
    
    // final check to see if it is still offscren or near offscreen -- if so just pop it in the center.
    BOOL mightBeOffscreen = NO;
    if (windowPoint.x < 20)
        mightBeOffscreen = YES;
    if ((windowPoint.x + windowSize.width + 20) > screenSize.width)
        mightBeOffscreen = YES;
    if ((windowPoint.y - windowSize.height - 20) < 0)
        mightBeOffscreen = YES;
    if ((windowPoint.y + windowSize.height + 20) > screenSize.height)
        mightBeOffscreen = YES;
    
    if (mightBeOffscreen) {
        windowPoint.x = screenSize.width/2 - windowSize.width/2;
        windowPoint.y = screenSize.height/2 - windowSize.height/2;
    }
    
    NSRect frame;
    frame.origin = windowPoint;
    frame.size = windowSize;
    [theWindow setFrame:frame display:NO];
    
    // NSBeep(); NSBeep();
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [theWindow makeKeyAndOrderFront:nil];
    
    return;
}
-(void)setupTimer {
    [countDownText setStringValue:@""];
    NSDate *_date = nil;
    alarmtime *alarmtime = [self getNearestalarmtime:&_date];
    self.currentalarmtime = _date;
    self.currentalarmtimeReason = alarmtime.nagText;
    self.currentalarmtimeDialogReason = alarmtime.dialogText;
    
    if (currentalarmtime == nil) {
        if (tickTimer) {
            [tickTimer invalidate];
            self.tickTimer = nil;
        }
        [countDownText setStringValue:@"No Timer"];
        return;
    }
    
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    self.warningDates = [NSMutableArray array];
    for (NSDictionary *dict in warnTimes) {
        components.minute = -[[dict objectForKey:@"minutes"] intValue];
        NSDate *warn = [gregorian dateByAddingComponents:components toDate:currentalarmtime options:0];
        if ([warn timeIntervalSinceNow] > 0) {
            [warningDates addObject:warn];
        }
    }
    
    self.pendingNags = [NSMutableArray array];
    for (NSDictionary *dict in nagTimes) {
        [pendingNags addObject:[dict objectForKey:@"minutes"]];
    }
    
    [components release];
    
    if (!tickTimer) {
        [self doTick:nil];
        self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(doTick:) userInfo:nil repeats:YES];
    }
    [self enqueueNext];
}
-(void)enqueueNext {
    if ([warningDates count] == 0) {
        // Okay, so this is nag time.
        // But first let's check if the alarm is still in the future
        int interval = [currentalarmtime timeIntervalSinceNow];
        if (interval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(doNag:) userInfo:nil repeats:NO];
        } else {
            int nag = [[pendingNags objectAtIndex:0] intValue] * 60;
            if ([pendingNags count] > 1)
                [pendingNags removeObjectAtIndex:0];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:nag target:self selector:@selector(doNag:) userInfo:nil repeats:NO];
        }
    } else {
        // Okay, so the alarm is in the future...
        NSDate *when = [warningDates objectAtIndex:0];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[when timeIntervalSinceNow] target:self selector:@selector(doWarning:) userInfo:nil repeats:NO];
        [warningDates removeObjectAtIndex:0];
    }
}
// Alarm time approaching
-(void)doWarning:(NSTimer *)t { 
    [self abortKeepFront];
    [nagWindow orderOut:nil];
    [self popWindowToFrontAwayFromCursor:warningWindow];
    int interval = [currentalarmtime timeIntervalSinceNow] / 60;
    if (interval > 0)
        [warningWhich setStringValue:[NSString stringWithFormat:@"In %i minutes",interval+1]];
    [warningReason setStringValue:currentalarmtimeReason];
    [self enqueueNext];
    [self setupKeepFrontFor:warningWindow];
}
// Alarm time is past
-(void)doNag:(NSTimer *)t {
    [self abortKeepFront];
    [warningWindow orderOut:nil];
    [self popWindowToFrontAwayFromCursor:nagWindow];
    int interval = [currentalarmtime timeIntervalSinceNow] / 60;
    if (interval < 0)
        [nagWhich setStringValue:[NSString stringWithFormat:@"%i minutes ago",-(interval+1)]];
    [nagReason setStringValue:currentalarmtimeReason];
    [self enqueueNext];
    [self setupKeepFrontFor:nagWindow];
}
-(void)doTick:(NSTimer *)t {
    [countDownReason setStringValue:currentalarmtimeDialogReason];
    int interval = [currentalarmtime timeIntervalSinceNow] / 60;
    if (interval > 0)
			[countDownText setStringValue:[NSString stringWithFormat:@"In %i minutes",interval]];
    else if (interval == 0)
        [countDownText setStringValue:@"right now"];
    else
        [countDownText setStringValue:[NSString stringWithFormat:@"%i minutes ago",-interval]];
}
#pragma mark KeepFront Stuff
-(void)setupKeepFrontFor:(NSWindow *)window {
    self.keepFrontWindow = window;
    self.putFronts = 0;
    self.keepFrontTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(keepFrontTick:) userInfo:nil repeats:YES]; 
}
-(void)keepFrontTick:(NSTimer *)t {
    NSDictionary *activeAppDict = [[NSWorkspace sharedWorkspace] activeApplication];
    NSString *activeBundleID = [activeAppDict objectForKey:@"NSApplicationBundleIdentifier"];
    NSString *currentBundleID = [[NSBundle mainBundle] bundleIdentifier];
    if (![activeBundleID isEqualToString:currentBundleID]) {
        putFronts++;
        if (putFronts < 10) {
            inWarning = YES;
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [keepFrontWindow makeKeyAndOrderFront:nil];
            inWarning = NO;
        } else {
            NSTimeInterval interval = [keepFrontTimer timeInterval];
            interval *= 2;
            [keepFrontTimer invalidate];
            putFronts = 2;
            self.keepFrontTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(keepFrontTick:) userInfo:nil repeats:YES]; 
        }
    } else {
        [keepFrontWindow orderFront:nil];
    }
}
-(void)abortKeepFront {
    [keepFrontTimer invalidate]; self.keepFrontTimer = nil;
    self.keepFrontWindow = nil;
}
@end

#pragma mark Functions
NSComparisonResult sortalarmtimes(id num1, id num2, void *context) {
    NSDateComponents *c1 = [num1 time];
    NSDateComponents *c2 = [num2 time];
    
    int val1 = c1.hour * 60 + c1.minute;
    int val2 = c2.hour * 60 + c2.minute;
    
    if (val1 < val2)
        return NSOrderedAscending;
    else if (val1 == val2)
        return NSOrderedSame;
    else
        return NSOrderedDescending;
}
NSComparisonResult sortWarnTimes(id num1, id num2, void *context) {
    int val1 =  [[num1 objectForKey:@"minutes"] intValue];
    int val2 =  [[num2 objectForKey:@"minutes"] intValue];
    
    if (val1 < val2)
        return NSOrderedDescending;
    else if (val1 == val2)
        return NSOrderedSame;
    else
        return NSOrderedAscending;
}

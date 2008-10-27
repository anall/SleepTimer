//
//  AppController.h
//  SleepTimer
//
//  Created by Andrea Nall on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
    NSCalendar *gregorian; // This is used enough might as well keep it around.

    NSMutableArray *bedtimes;
    NSMutableArray *warnTimes;
    NSMutableArray *nagTimes;

    IBOutlet NSWindow *mainWindow;
    IBOutlet NSTableColumn *prefsTimeColumn;
    IBOutlet NSArrayController *bedtimeArrayController;
    IBOutlet NSArrayController *warnTimeArrayController;

    IBOutlet NSWindow *warningWindow;
    IBOutlet NSTextField *warningWhich;
    IBOutlet NSTextField *warningReason;

    IBOutlet NSWindow *nagWindow;
    IBOutlet NSTextField *nagWhich;
    IBOutlet NSTextField *nagReason;

    IBOutlet NSTextField *countDownText;
    IBOutlet NSTextField *countDownReason;

    BOOL inWarning;
    NSDate *skipPast;
    NSDate *currentBedtime;
    NSString *currentBedtimeReason;
    NSString *currentBedtimeDialogReason;
    NSMutableArray *warningDates;
    NSMutableArray *pendingNags;

    NSTimer *timer;
    NSTimer *tickTimer;

    NSTimer *keepFrontTimer;
    NSWindow *keepFrontWindow;
    int putFronts;
}
@property (retain) NSMutableArray *bedtimes;
@property (retain) NSMutableArray *warnTimes;
@property (retain) NSMutableArray *nagTimes;

@property (retain) NSWindow *mainWindow;
@property (retain) NSTableColumn *prefsTimeColumn;
@property (retain) NSArrayController *bedtimeArrayController;
@property (retain) NSArrayController *warnTimeArrayController;

@property (retain) NSWindow *warningWindow;
@property (retain) NSTextField *warningWhich;
@property (retain) NSTextField *warningReason;

@property (retain) NSWindow *nagWindow;
@property (retain) NSTextField *nagWhich;
@property (retain) NSTextField *nagReason;

@property (retain) NSTextField *countDownText;
@property (retain) NSTextField *countDownReason;

@property (retain) NSDate *skipPast;
@property (retain) NSDate *currentBedtime;
@property (retain) NSString *currentBedtimeReason;
@property (retain) NSString *currentBedtimeDialogReason;
@property (retain) NSMutableArray *warningDates;
@property (retain) NSMutableArray *pendingNags;

@property (retain) NSTimer *tickTimer;
@property (retain) NSTimer *timer;

@property (retain) NSTimer *keepFrontTimer;
@property (retain) NSWindow *keepFrontWindow;
@property int putFronts;

#pragma mark Actions
-(IBAction)sortBedtimes:(id)sender;
-(IBAction)sortWarnTimes:(id)sender;
-(IBAction)resetBedtime:(id)sender;
-(IBAction)dismissWindow:(id)sender;

#pragma mark Test Actions
-(IBAction)testWarning:(id)sender;

#pragma mark Settings
-(void)loadSettings;
-(void)saveSettings;

@end

NSComparisonResult sortBedtimes(id num1, id num2, void *context);
NSComparisonResult sortWarnTimes(id num1, id num2, void *context);
//
//  AppDelegate.m
//  Mavericks Stuttering
//
//  Created by Sean Dougall on 12/30/13.
//  Copyright (c) 2013 Figure 53. All rights reserved.
//

#import "AppDelegate.h"
#import "MSDWindow.h"

@interface AppDelegate ()
{
    NSMutableArray *_renderingWindows;
    NSUUID *_runToken;
}

@end

#pragma mark -

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _renderingWindows = [NSMutableArray array];
}

- (IBAction)selectRenderingMode:(id)sender
{
    self.renderingMode = [sender indexOfSelectedItem];
}

- (void)autoStopForToken:(NSUUID *)token
{
    if ( [token isEqual:_runToken] )
        [self stop:self];
}

- (IBAction)run:(id)sender
{
    [self stop:sender];
    
    _runToken = [NSUUID UUID];
    
    for ( NSScreen *screen in [NSScreen screens] )
    {
        MSDWindow *window = [[MSDWindow alloc] initWithScreen:screen mode:self.renderingMode];
        [_renderingWindows addObject:window];
        [window startRendering];
    }
    
    [self performSelector:@selector( autoStopForToken: ) withObject:_runToken afterDelay:10.0];
}

- (IBAction)stop:(id)sender
{
    _runToken = nil;
    
    for ( MSDWindow *window in [NSArray arrayWithArray:_renderingWindows] )
    {
        [window stopRendering];
        [_renderingWindows removeObject:window];
    }
}

@end

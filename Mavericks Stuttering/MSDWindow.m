//
//  MSDWindow.m
//  Mavericks Stuttering
//
//  Created by Sean Dougall on 12/30/13.
//  Copyright (c) 2013 Figure 53. All rights reserved.
//

#import "MSDWindow.h"
#import "MSDView.h"

@implementation MSDWindow

- (id)initWithScreen:(NSScreen *)screen mode:(MSDRenderingMode)renderingMode
{
    NSRect frame = screen.frame;
    
    /*
     NOTE: This isn't quite the right test -- what matters is not whether or not this screen is the main
     screen in terms of the display arrangement, but whether it's the primary hardware display (e.g. the
     Color LCD on a MacBook Pro). However, that is the main screen in most cases, so for simplicity, I'm
     using this non-robust test here.
     */
    if ( [[NSScreen mainScreen] isEqual:screen] )
    {
        if ( renderingMode == kMSDRenderingModeFullExternal || renderingMode == kMSDRenderingModePartialAll )
        {
            frame.origin.y += 10.0;
            frame.size.height -= 10.0;
        }
    }
    else
    {
        if ( renderingMode == kMSDRenderingModeFullMain || renderingMode == kMSDRenderingModePartialAll )
        {
            frame.origin.y += 10.0;
            frame.size.height -= 10.0;
        }
    }
    
    self = [super initWithContentRect:frame
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO
                               screen:screen];
    if ( self )
    {
        MSDView *newView = [[MSDView alloc] initWithScreen:screen];
        [self setReleasedWhenClosed:NO];
        [self setDisplaysWhenScreenProfileChanges:YES];
        [self setHasShadow:NO];
        [self setBackgroundColor:[NSColor blackColor]];
        if ( renderingMode == kMSDRenderingModeFullNonOpaque )
        {
            // Any alpha value < 1.0 means we're technically not occluding the whole screen, even if nothing is effectively visible.
            // However, it does incur a lot more overhead for the window server.
            [self setOpaque:NO];
            [self setAlphaValue:0.999];
        }
        else
        {
            [self setOpaque:YES];
        }
        [self setHidesOnDeactivate:NO];
        [self setFrame:frame display:NO];
        [self setContentView:newView];
        [self setCollectionBehavior:NSWindowCollectionBehaviorStationary];
        [self setLevel:NSScreenSaverWindowLevel];   // Yes, we do need to be at the highest possible level. However, it doesn't seem to make a difference unless choosing a lower level makes the menu bar appear (which is obviously not acceptable for projections).
    }
    return self;
}

- (void)startRendering
{
    [self orderFront:self];
    [(MSDView *)self.contentView startRendering];
}

- (void)stopRendering
{
    [(MSDView *)self.contentView stopRendering];
    [self orderOut:self];
}

@end

//
//  MSDView.m
//  Mavericks Stuttering
//
//  Created by Sean Dougall on 12/30/13.
//  Copyright (c) 2013 Figure 53. All rights reserved.
//

#import "MSDView.h"
#import <OpenGL/OpenGL.h>

#define FRAMES_PER_CYCLE 30

@interface MSDView ()
{
    CVDisplayLinkRef _displayLink;
    int _i;                 // For testing purposes, we'll render a repeating series of FRAMES_PER_CYCLE frames. This is our index in that series.
    NSDate *_cycleStart;    // Keep track of when the cycle started, so we can get real fps. The display link is delusional, and always reports 60 fps.
}

@end

#pragma mark -

@implementation MSDView

- (CVReturn) displayLinkCallback:(const CVTimeStamp *)inOutputTime
{
    double referenceTime = (double)(inOutputTime->videoTime)/(double)(inOutputTime->videoTimeScale);
    
    // Render a repeating pattern to make stuttering visually obvious. We can skip this rendering entirely and still see the fps drop in certain circumstances, as long as -flushBuffer is getting called.
    CGLLockContext( self.openGLContext.CGLContextObj );
    [self.openGLContext makeCurrentContext];
    glClearColor( 0.0, 0.0, 0.0, 1.0 );
    glClear( GL_COLOR_BUFFER_BIT );
    
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    glViewport( 0, 0, self.frame.size.width, self.frame.size.height );
    glOrtho( -1.0, 1.0, -1.0, 1.0, -1.0, 1.0 );
    
    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
    glPushMatrix();
    
    glTranslatef( 0.0, sin( 2.0 * referenceTime ), 0.0 );
    glBegin( GL_QUADS );
    glColor4f( 1.0, 0.0, 0.0, 0.5 );
    glVertex2f( -1.0, -0.03 );
    glVertex2f( -1.0, 0.03 );
    glVertex2f( 1.0, 0.03 );
    glVertex2f( 1.0, -0.03 );
    glEnd();
    
    glPopMatrix();
    glPushMatrix();
    
    glTranslatef( sin( 2.0 * referenceTime ), 0.0, 0.0 );
    glBegin( GL_QUADS );
    glColor4f( 0.0, 1.0, 0.0, 0.5 );
    glVertex2f( -0.03, -1.0 );
    glVertex2f( 0.03, -1.0 );
    glVertex2f( 0.03, 1.0 );
    glVertex2f( -0.03, 1.0 );
    glEnd();
    
    glPopMatrix();
    
    [self.openGLContext flushBuffer];   // This is causing the stuttering in question, by blocking for inordinately long times.
    _i = ( _i + 1 ) % 30;
    CGLUnlockContext( self.openGLContext.CGLContextObj );
    
    // Occasionally log our refresh rate.
    if ( _i == 0 )
    {
        NSDate *now = [NSDate date];
        if ( _cycleStart )
        {
            NSTimeInterval interval = [now timeIntervalSinceDate:_cycleStart];
            if ( interval != 0.0 )
                NSLog( @"%p rendering at %0.1f fps.", self, (double)FRAMES_PER_CYCLE / interval );
        }
        _cycleStart = now;
    }
    
    return kCVReturnSuccess;
}

static CVReturn _CVDisplayLinkDisplayCallback( CVDisplayLinkRef displayLink,
                                              const CVTimeStamp *inNow,
                                              const CVTimeStamp *inOutputTime,
                                              CVOptionFlags flagsIn,
                                              CVOptionFlags *flagsOut,
                                              void *displayLinkContext )
{
    return [(__bridge MSDView *)(displayLinkContext) displayLinkCallback:inOutputTime];
}

- (id)initWithScreen:(NSScreen *)screen
{
    // Roll our own pixel format attributes, and set up a display link while we're at it.
    
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAWindow,      // Deprecated in 10.9, but doesn't seem to make a difference either way.
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        0
    };
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    
    self = [super initWithFrame:screen.frame pixelFormat:format];
    if ( self )
    {
        CVReturn error = kCVReturnSuccess;
        
        error = CVDisplayLinkCreateWithCGDisplay( [self.window.screen.deviceDescription[@"NSScreenNumber"] unsignedShortValue], &_displayLink );
        if ( error )
        {
            NSLog( @"Error creating display link: %d", error );
            _displayLink = NULL;
            return nil;
        }
        
        error = CVDisplayLinkSetOutputCallback( _displayLink, &_CVDisplayLinkDisplayCallback, (__bridge void *)(self) );
        if ( error )
        {
            NSLog( @"Error setting display link callback: %d", error );
            if ( _displayLink )
            {
                CVDisplayLinkRelease( _displayLink );
                _displayLink = NULL;
            }
            return nil;
        }

    }
    return self;
}

- (void)dealloc
{
    if ( _displayLink )
    {
        [self stopRendering];
        CVDisplayLinkRelease( _displayLink );
        _displayLink = NULL;
    }
}

- (void)startRendering
{
    CVDisplayLinkStart( _displayLink );
}

- (void)stopRendering
{
    CVDisplayLinkStop( _displayLink );
    while ( CVDisplayLinkIsRunning( _displayLink ) )
        usleep( 10000 );
}

@end

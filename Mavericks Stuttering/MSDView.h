//
//  MSDView.h
//  Mavericks Stuttering
//
//  Created by Sean Dougall on 12/30/13.
//  Copyright (c) 2013 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>

@interface MSDView : NSOpenGLView

- (id)initWithScreen:(NSScreen *)screen;
- (void)startRendering;
- (void)stopRendering;

@end

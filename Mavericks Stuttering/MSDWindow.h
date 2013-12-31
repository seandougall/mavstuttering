//
//  MSDWindow.h
//  Mavericks Stuttering
//
//  Created by Sean Dougall on 12/30/13.
//  Copyright (c) 2013 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MSDRenderingModes.h"

@interface MSDWindow : NSWindow

- (id)initWithScreen:(NSScreen *)screen mode:(MSDRenderingMode)renderingMode;
- (void)startRendering;
- (void)stopRendering;

@end

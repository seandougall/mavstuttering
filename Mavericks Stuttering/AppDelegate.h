//
//  AppDelegate.h
//  Mavericks Stuttering
//
//  Created by Sean Dougall on 12/30/13.
//  Copyright (c) 2013 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MSDRenderingModes.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) MSDRenderingMode renderingMode;

- (IBAction)selectRenderingMode:(id)sender;
- (IBAction)run:(id)sender;
- (IBAction)stop:(id)sender;

@end

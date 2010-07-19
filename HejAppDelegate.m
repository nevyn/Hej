//
//  HejAppDelegate.m
//  Hej
//
//  Created by Joachim Bengtsson on 2010-07-19.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import "HejAppDelegate.h"

@implementation HejAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[spelvy enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
}

@end

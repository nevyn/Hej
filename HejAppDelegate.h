//
//  HejAppDelegate.h
//  Hej
//
//  Created by Joachim Bengtsson on 2010-07-19.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Spelvyn.h"

@interface HejAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSWindow *window;
    IBOutlet Spelvyn *spelvy;
}

@end

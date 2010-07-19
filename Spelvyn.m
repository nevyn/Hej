//
//  Spelvyn.m
//  Hej
//
//  Created by Joachim Bengtsson on 2010-07-19.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import "Spelvyn.h"

static float frand() {
	return (rand()%10000)/10000.;
}

@implementation Spelvyn

- (id)initWithFrame:(NSRect)frame {
  if(![super initWithFrame:frame]) return nil;
  
  timer = [NSTimer tc_scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer*t) {
  	[self setNeedsDisplay:YES];
  }];
  
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [[NSColor colorWithCalibratedRed:frand() green:frand() blue:frand() alpha:1] set];
  NSRectFill(dirtyRect);
}

@end

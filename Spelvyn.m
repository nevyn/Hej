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

static double sin1(double f) {
	return (sin(f)+1.0)/2.0;
}

@implementation Entity
@synthesize v, a, p;
-(id)init;
{
	self.p = [BNZVector vectorX:0 y:0];
	self.v = [BNZVector vectorX:0 y:0];
	self.a = [BNZVector vectorX:0 y:0];
	return self;
}
-(void)update:(NSTimeInterval)delta;
{
	self.v = [[self.v sumWithVector:[self.a vectorScaledBy:delta]] vectorScaledBy:0.95];
	self.p = [self.p sumWithVector:[self.v vectorScaledBy:delta]];
}
@end


@implementation Spelvyn

- (id)initWithFrame:(NSRect)frame {
  if(![super initWithFrame:frame]) return nil;
  
  energy = 100;
  
  __block NSDate *lastUpdate = [NSDate date];
  timer = [NSTimer tc_scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer*t) {
  	[self setNeedsDisplay:YES];
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [now timeIntervalSinceDate:lastUpdate];
    [player update:delta];
    lastUpdate = now;
    
    energy = MIN(200, energy+= delta*40);
    energyBar.floatValue = energy;
  }];

  
  walls = $marray(
  	
  );
  
  player = [Entity new];
  
  return self;
}

-(void)setFrame:(NSRect)frameRect;
{
	[super setFrame:frameRect];
	self.bounds = NSMakeRect(0, 0, 1024, 768);
}

- (void)drawRect:(NSRect)dirtyRect {
	static float woooh = 0;
  NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
  woooh = sin1(t)*0.2;
	[[NSColor colorWithCalibratedWhite:woooh alpha:1] set];
  NSRectFill(dirtyRect);
  
  [[NSColor redColor] set];
  for (BNZLine *line in walls) {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:line.start.asPoint];
    [path lineToPoint:line.end.asPoint];
    [path setLineWidth:4];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path stroke];
  }
  
  if(drawingLine) {
    [[NSColor greenColor] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:drawingLine.start.asPoint];
    [path lineToPoint:drawingLine.end.asPoint];
    [path setLineWidth:4];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path stroke];
	}

	[[NSColor yellowColor] set];  
  NSBezierPath *plShape = [NSBezierPath bezierPathWithRect:
  	CGRectMake(player.p.x-50, player.p.y-50, 100, 100)	
  ];
  [plShape fill];

  
}


- (void)mouseDown:(NSEvent *)theEvent;
{
	drawingLine = [BNZLine lineAt:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil]) to:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil])];
}
- (void)mouseDragged:(NSEvent *)theEvent;
{
	if(!drawingLine)
  	drawingLine = [BNZLine lineAt:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil]) to:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil])];
	else
		drawingLine = [BNZLine lineAt:drawingLine.start to:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil])];
    
  if(drawingLine.length > 20) {
    if(energy > 10) {
      energy -= 10;  
		  [walls addObject:drawingLine];
			drawingLine = [BNZLine lineAt:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil]) to:VecCG([self convertPoint:theEvent.locationInWindow fromView:nil])];
    } else
    	drawingLine = nil;
  }

}
- (void)mouseUp:(NSEvent *)theEvent;
{
  if(energy > 10) {
    energy -= 10;  
 	 [walls addObject:drawingLine];
  }
  drawingLine = nil;
}

-(BOOL)isFlipped;
{
	return YES;
}

-(BOOL)acceptsFirstResponder
{
	return YES;
}

-(void)setActionVector;
{
	actionVector.width = keys[Leftkey] ? -1 : (keys[Rightkey] ? 1 : 0);
	actionVector.height = keys[Downkey] ? 1 : (keys[Upkey] ? -1 : 0);
	
	player.a = VecXY(actionVector.width*950, actionVector.height*950);
}
#define setkeys(keychar, keyname, value) 	if([[theEvent charactersIgnoringModifiers] rangeOfString:keychar].location != NSNotFound) keys[keyname] = value;
- (void)keyDown:(NSEvent *)theEvent;
{
	setkeys(@"a", Leftkey, YES);
	setkeys(@"d", Rightkey, YES);
	setkeys(@"w", Upkey, YES);
	setkeys(@"s", Downkey, YES);

	[self setActionVector];
}
- (void)keyUp:(NSEvent *)theEvent;
{
	setkeys(@"a", Leftkey, NO);
	setkeys(@"d", Rightkey, NO);
	setkeys(@"w", Upkey, NO);
	setkeys(@"s", Downkey, NO);
	[self setActionVector];
}


@end

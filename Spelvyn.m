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
@synthesize v, a, p, r, ra, rv;
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
	rv = (rv + ra*delta)*0.9;
	r += rv*delta;
}
@end

@implementation Bomb
@synthesize countdown;
-(id)initWithTime:(float)time;
{
  if(![super init]) return nil;
	countdown = time;
  return self;
}

-(void)update:(NSTimeInterval)delta {
  countdown -= delta;
  [super update:delta];
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
    for(Bomb *aBomb in bombs.copy) {
      [aBomb update:delta];
      if(aBomb.countdown <= 0) {
        // Explode
        [bombs removeObject:[[aBomb retain] autorelease]];
        
      }
    }
    
    lastUpdate = now;
    
    energy = MIN(500, energy+= delta*60);
    energyBar.floatValue = energy;
  }];

  
  walls = $marray(
  	
  );
  
  bombs = $marray();
  
  player = [Entity new];
  player.p = VecXY(100,100);
  
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
  NSBezierPath *plShape = [NSBezierPath bezierPath];
  [plShape moveToPoint:NSMakePoint(0, 30)];
  [plShape lineToPoint:NSMakePoint(30, -30)];
  [plShape lineToPoint:NSMakePoint(0, -10)];
  [plShape lineToPoint:NSMakePoint(-30, -30)];
  [plShape closePath];
  NSAffineTransform *r = [NSAffineTransform transform];
  [r translateXBy:player.p.x yBy:player.p.y];
  [r rotateByRadians:player.r];
  [r translateXBy:0 yBy:10];
  [plShape transformUsingAffineTransform:r];
  [plShape fill];

  for(Bomb *aBomb in bombs) {
    [[NSColor colorWithCalibratedRed:1. green:aBomb.countdown blue:aBomb.countdown alpha:1.] set];
    NSBezierPath *bomb = [NSBezierPath bezierPathWithOvalInRect:CGRectMake(-5., -5., 10., 10.)];
    NSAffineTransform *t = [NSAffineTransform transform];
    [t translateXBy:aBomb.p.x yBy:aBomb.p.y];
    if(aBomb.countdown < 0.1) {
      [[NSColor yellowColor] set];
      [t scaleBy:aBomb.countdown * 100.];
    } else
      [t scaleBy:aBomb.countdown];
    [bomb transformUsingAffineTransform:t];
    [bomb fill];
  }
  
  
  
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


-(void)layBomb {
  NSLog(@"Bomb!");
  Bomb *bomb = [[Bomb alloc] initWithTime:1.];
  bomb.p = [BNZVector vectorX:player.p.x y:player.p.y];
	[bombs addObject:bomb];
}
   
   
-(void)setActionVector;
{
	//actionVector.width = keys[Leftkey] ? -1 : (keys[Rightkey] ? 1 : 0);
	actionVector.height = keys[Downkey] ? -1 : (keys[Upkey] ? 1 : 0);
	rotationAction = keys[Leftkey] ? -1 : (keys[Rightkey] ? 1 : 0);
	
	player.a = [VecXY(actionVector.width*950, actionVector.height*950) rotateByRadians:player.r];
	player.ra = rotationAction*M_PI*6.;
}
#define setkeys(keychar, keyname, value) 	if([[theEvent charactersIgnoringModifiers] rangeOfString:keychar].location != NSNotFound) keys[keyname] = value;
- (void)keyDown:(NSEvent *)theEvent;
{
	setkeys(@"a", Leftkey, YES);
	setkeys(@"d", Rightkey, YES);
	setkeys(@"w", Upkey, YES);
	setkeys(@"s", Downkey, YES);
  
  if(theEvent.keyCode == 0x31) [self layBomb];
  
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

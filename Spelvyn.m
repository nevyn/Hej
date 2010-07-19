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
@synthesize constantRotation, linearMovement;
@synthesize temporary, lifetime;
-(id)init;
{
	self.p = [BNZVector vectorX:0 y:0];
	self.v = [BNZVector vectorX:0 y:0];
	self.a = [BNZVector vectorX:0 y:0];
	return self;
}
-(void)update:(NSTimeInterval)delta;
{
  if(!linearMovement)
    self.v = [[self.v sumWithVector:[self.a vectorScaledBy:delta]] vectorScaledBy:0.95];
	self.p = [self.p sumWithVector:[self.v vectorScaledBy:delta]];
  if(!constantRotation)
    rv = (rv + ra*delta)*0.9;
	r += rv*delta;
  
  if(temporary)
    lifetime -= delta;
}
@end

@implementation Bomb
@synthesize countdown, stage;
-(id)initWithTime:(float)time;
{
  if(![super init]) return nil;
	countdown = time;
  stage = 0;
  return self;
}

-(void)update:(NSTimeInterval)delta {
  countdown -= delta;
  if(stage==1) stage = 2;
  if(countdown < 0.1 && stage==0) stage = 1;
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
    
    if(!NSPointInRect(player.p.asPoint, self.bounds)) {
    	BNZVector *mid = VecXY(self.bounds.size.width/2, self.bounds.size.height/2);
    	BNZVector *towardMid = [mid differenceFromVector:player.p];
      player.v = towardMid;
    }
    
    [player update:delta];
    for(Bomb *aBomb in bombs.copy) {
      [aBomb update:delta];
      if(aBomb.stage == 1) {
        for(BNZLine *w in walls.copy) {
          float dist1 = [[w.start differenceFromVector:aBomb.p] length];
          float dist2 = [[w.end differenceFromVector:aBomb.p] length];
          if(dist1 < 55. && dist2 < 55.) {
            Entity *p1 = [Entity new];
            Entity *p2 = [Entity new];
            Entity *p3 = [Entity new];
            p1.p = [BNZVector vectorX:w.start.x y:w.start.y];
            p2.p = [BNZVector vectorX:w.start.x y:w.start.y];
            p3.p = [BNZVector vectorX:w.end.x y:w.end.y];
            p1.temporary = p2.temporary = p3.temporary = YES;
            p1.lifetime = p2.lifetime = p3.lifetime = 0.8;
            p1.constantRotation = p2.constantRotation = p3.constantRotation = YES;
            p1.linearMovement = p2.linearMovement = p3.linearMovement = YES;
            p1.rv = p2.rv = p3.rv = frand()*20.;
            p1.v = [BNZVector vectorX:(frand()*200)-100 y:(frand()*200)-100];
            p2.v = [BNZVector vectorX:(frand()*200)-100 y:(frand()*200)-100];
            p3.v = [BNZVector vectorX:(frand()*200)-100 y:(frand()*200)-100];
            [wallPieces addObject:p1];
            [wallPieces addObject:p2];
            [wallPieces addObject:p3];
            [walls removeObject:w];
          }
        }
      }      
      if(aBomb.countdown <= 0) {
        // Explode
        [bombs removeObject:[[aBomb retain] autorelease]];
        
      }
    }
    
    for(Entity *wp in wallPieces.copy) {
      [wp update:delta];
      if(wp.lifetime <= 0)
        [wallPieces removeObject:wp];
    }
        
    lastUpdate = now;
    
    energy = MIN(500, energy+= delta*60);
    energyBar.floatValue = energy;
  }];

  
  walls = $marray(
  	
  );
  wallPieces = $marray();
  
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
  
  for(Entity *wp in wallPieces) {
    [[NSColor colorWithCalibratedRed:1. green:0. blue:0. alpha:wp.lifetime/0.8] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(-4,0)];
    [path lineToPoint:NSMakePoint(4, 0)];
    [path setLineWidth:4];
    [path setLineCapStyle:NSRoundLineCapStyle];
    
    NSAffineTransform *r = [NSAffineTransform transform];
    [r translateXBy:wp.p.x yBy:wp.p.y];
    [r rotateByRadians:wp.r];
    [path transformUsingAffineTransform:r];
    
    [path stroke];
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

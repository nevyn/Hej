//
//  Spelvyn.h
//  Hej
//
//  Created by Joachim Bengtsson on 2010-07-19.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BNZLine.h"

enum {
	Upkey,
	Downkey,
	Leftkey,
	Rightkey,
  
	ActionKeyCount
};

@interface Entity : NSObject
{
  BNZVector *v, *a, *p;
 	float rv, ra, r;
  
  BOOL  constantRotation;
  BOOL  linearMovement;
  
  BOOL  temporary;
  float lifetime;
}
@property (retain) BNZVector *v;
@property (retain) BNZVector *a;
@property (retain) BNZVector *p;
@property float rv;
@property float ra;
@property float r;
@property BOOL constantRotation;
@property BOOL linearMovement;
@property BOOL temporary;
@property float lifetime;
-(void)update:(NSTimeInterval)delta;
@end


@interface Bomb : Entity {
	float countdown;
  int   stage;
}
@property float countdown;
@property int stage;
-(id)initWithTime:(float)time;
@end


@interface Spelvyn : NSView {
	NSTimer *timer;
  NSMutableArray *walls;
  BNZLine *drawingLine;
  BOOL keys[ActionKeyCount];
 	CGSize actionVector;
 	float rotationAction;
  Entity *player;
  float energy;
  IBOutlet NSLevelIndicator *energyBar;
  NSMutableArray *bombs;
  NSMutableArray *wallPieces;
}

@end
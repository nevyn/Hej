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
}
@property (retain) BNZVector *v;
@property (retain) BNZVector *a;
@property (retain) BNZVector *p;
-(void)update:(NSTimeInterval)delta;
@end



@interface Spelvyn : NSView {
	NSTimer *timer;
  NSMutableArray *walls;
  BNZLine *drawingLine;
  BOOL keys[ActionKeyCount];
 	CGSize actionVector;
  Entity *player;
  float energy;
  IBOutlet NSLevelIndicator *energyBar;
}

@end

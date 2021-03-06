//
//  BNZLine.h
//  Aurora2D
//
//  Created by Joachim Bengtsson on 2007-12-10.
//  Copyright 2007 Joachim Bengtsson. All rights reserved.
//

#import "BNZVector.h"

typedef enum {
    BNZLinesIntersect = 0,
    BNZLinesDoNotIntersect,
    BNZLinesAreParallel,
    BNZLinesAreCoincident
} BNZLineIntersectionResult;

@interface BNZLine : NSObject {
    BNZVector *start, *end;
}

-initAt:(BNZVector*)start_ to:(BNZVector*)end_;
+lineAt:(BNZVector*)start_ to:(BNZVector*)end_;


-(BNZVector*)start;
-(BNZVector*)end;
-(void)setStart:(BNZVector*)start;
-(void)setEnd:(BNZVector*)end;

-(BNZVector*)vector;

-(BNZLineIntersectionResult)getIntersectionPoint:(BNZVector**)intersectionPoint_ withLine:(BNZLine*)other;
-(BNZVector*)intersectionPointWithLine:(BNZLine*)other;

-(CGFloat)distanceToPoint:(BNZVector*)point;
-(CGFloat)length;
@end

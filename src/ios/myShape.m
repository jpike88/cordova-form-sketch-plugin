//
//  myShape.m
//  DrawingApp
//
//  Created by Lion User on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Class to describe the shapes I use

#import "myShape.h"

@interface myShape() {
    
}
-(bool)pointOnLine:(CGPoint) point;
-(bool)pointContainedInCircle:(CGPoint) point;
@end

@implementation myShape
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize color = _color;
@synthesize selected = _selected;
@synthesize lineWidth = _lineWidth;
@synthesize isDashed = _isDashed;
@synthesize shape = _shape;


#pragma mark - Init codes
-(id)init {
    self = [super init];
    if(self) {
        _selected = false;
    }
    return self;
}


CGPoint subtractVector(CGPoint, CGPoint);
CGPoint addVector(CGPoint, CGPoint);
CGPoint multiplyVectorByScalar(CGPoint, float);
float distanceBetweenTwoPoints(CGPoint, CGPoint);
float dotProductOfTwoPoints(CGPoint, CGPoint);
float lengthSquared(CGPoint, CGPoint);
float distanceFromPointToLineSegment(CGPoint, CGPoint, CGPoint);


// Algebraic manupulations between two points
CGPoint subtractVector(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

CGPoint addVector(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

CGPoint multiplyVectorByScalar(CGPoint a, float f) {
    return CGPointMake(f * a.x, f* a.y);
}

// Calculates distance between two points
float distanceBetweenTwoPoints(CGPoint a, CGPoint b) {
    float dx = b.x - a.x;
    float dy = b.y - a.y;
    
    return sqrtf(dx * dx + dy * dy);
}

// calculates the dot prodoct between two vectors, represented by CGPoints
float dotProductOfTwoPoints(CGPoint a, CGPoint b) {
    return a.x * b.x + a.y * b.y;
}

// Something...
float lengthSquared(CGPoint a, CGPoint b) {
    return distanceBetweenTwoPoints(a, b) * distanceBetweenTwoPoints(a, b);
}

// calculates the point to line segment distance
float distanceFromPointToLineSegment(CGPoint a, CGPoint b, CGPoint p) {
    float l2 = lengthSquared(a, b);
    
    if(l2 == 0.0f)
        return distanceBetweenTwoPoints(p, a);
    
    float t = dotProductOfTwoPoints(subtractVector(p, a), subtractVector(b, a)) / l2;
    
    if(t < 0.0f)
        return distanceBetweenTwoPoints(p, a);
    else if(t > 1.0f)
        return distanceBetweenTwoPoints(p, b);
    
    CGPoint projection = addVector(a, multiplyVectorByScalar(subtractVector(b, a), t));
    
    return distanceBetweenTwoPoints(p, projection);
}



-(id)initCopy:(myShape *)input {
    self = [[myShape alloc] init];
    
    if(self) {
        _startPoint.x = input.startPoint.x;
        _startPoint.y = input.startPoint.y;
        _endPoint.x = input.endPoint.x;
        _endPoint.y = input.endPoint.y;
        _color = input.color;
        _selected = input.selected;
        _lineWidth = input.lineWidth;
        _shape = input.shape;
        _isDashed = input.isDashed;        
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    myShape *c = [[myShape alloc] initCopy:self];
    return c;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // wat
    self = [[myShape alloc] init];
    if(self) {
        _startPoint = [aDecoder decodeCGPointForKey:@"startPoint"];
        _endPoint = [aDecoder decodeCGPointForKey:@"endPoint"];
        _color = [aDecoder decodeIntegerForKey:@"color"];
        _selected = [aDecoder decodeBoolForKey:@"selected"];
        _isDashed = [aDecoder decodeBoolForKey:@"isDashed"];
        _lineWidth = [aDecoder decodeIntForKey:@"lineWidth"];
        _shape = [aDecoder decodeIntForKey:@"shape"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:_startPoint forKey:@"startPoint"];
    [aCoder encodeCGPoint:_endPoint forKey:@"endPoint"];
    [aCoder encodeInteger:_color  forKey:@"color"];
    [aCoder encodeBool:_selected forKey:@"selected"];
    [aCoder encodeBool:_isDashed forKey:@"isDashed"];
    [aCoder encodeInt:_lineWidth forKey:@"lineWidth"];
    [aCoder encodeInt:_shape forKey:@"shape"];
}

#pragma mark - Select Shapes

-(bool)pointContainedInShape:(CGPoint) point {
    if(_shape == 0) {    // Line
        return [self pointOnLine:point];
    }
    else if(_shape == 1) {   // Rectangle
        CGRect rectangle = CGRectMake(_startPoint.x,
                                      _startPoint.y,
                                      _endPoint.x - _startPoint.x,
                                      _endPoint.y - _startPoint.y);
        
        return CGRectContainsPoint(rectangle, point);
    }
    else if(_shape == 2) {   // Circle
        return [self pointContainedInCircle:point];
    }
    else {
        //NSLog(@"Error! Shouldn't be here!");
        return false;
    }
}

-(bool)pointOnLine:(CGPoint) point {
    

    return distanceFromPointToLineSegment(_startPoint, _endPoint, point) < 13.0f;
}

-(bool)pointContainedInCircle:(CGPoint) point {
    float r0, r, dx0, dy0, dx, dy;
    dx0 = _endPoint.x - _startPoint.x;
    dy0 = _endPoint.y - _startPoint.y;
    dx = point.x - _startPoint.x;
    dy = point.y - _startPoint.y;
    
    r0 = sqrtf(dx0*dx0 + dy0*dy0);  // Radius of our shape
    r = sqrtf(dx*dx + dy*dy);   // Radius of touch to center
    
    r0 = r0 < 0.0f ? (r0 * -1.0f) : r0;
    r = r < 0.0f ? (r * -1.0f) : r;
    
    if(r <= r0)
        return true;
    else
        return false;
}


@end

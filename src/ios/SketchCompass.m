//
//  SketchCompass.m
//  FormPigeon
//
//  Created by Joshua Pike on 26/08/13.
//  Copyright (c) 2013 Joshua Pike. All rights reserved.
//

#import "SketchCompass.h"
#import "ECS189DrawingViewController.h"
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation SketchCompass

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_vc.scrollView];
    [self doTransform:tempPoint];
    
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_vc.scrollView];
    [self doTransform:tempPoint];
            
    
}

-(void)doTransform:(CGPoint)tempPoint{
    CGPoint center = self.center;
    
    int quadrant = 0;
    
    
    int deltaY = tempPoint.y - center.y;
    int deltaX = tempPoint.x - center.x;
    
    
    // get quadrant.
    if(deltaY < 0 && deltaX >= 0){
        quadrant = 1;
    } else if (deltaY >= 0 && deltaX >= 0){
        quadrant = 2;
    } else if (deltaY >= 0 && deltaX < 0){
        quadrant = 3;
    } else {
        quadrant = 4;
    }
    
    deltaX = abs(deltaX);
    deltaY = abs(deltaY);
    float rads = atan((float)deltaY / (float)deltaX);
    float angle = RADIANS_TO_DEGREES(rads);
    
    if(quadrant == 1){
        angle = 90 - angle;
    } else if(quadrant == 2){
        angle = 90 + angle;
    } else if(quadrant == 3){
        angle = 270 - angle;
    } else{
        angle = 270 + angle;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.01f];
    
    [self.arrow setTransform: CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle))];
    
    [UIView commitAnimations];
    _vc.degrees = angle;

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_vc.scrollView];
    [self doTransform:tempPoint];
    
    
}

@end

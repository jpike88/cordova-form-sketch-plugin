//
//  FPSketchScrollView.m
//  FormPigeon
//
//  Created by Joshua Pike on 14/02/2015.
//  Copyright (c) 2015 Joshua Pike. All rights reserved.
//

#import "FPSketchScrollView.h"
#import "ECS189DrawingViewController.h"
@implementation FPSketchScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if ([[touches allObjects] count] == 1) {
         [_sketchView touchesBegan:touches withEvent:event];
    } else {
     [super touchesBegan:touches withEvent:event];        
    }
    

    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([[touches allObjects] count] == 1) {
         [_sketchView touchesMoved:touches withEvent:event];
    } else {
     [super touchesMoved:touches withEvent:event];
    }
    


}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([[touches allObjects] count] == 1) {
        [_sketchView touchesEnded:touches withEvent:event];
    } else {
    [super touchesEnded:touches withEvent:event];
    }
    
    
    
}

@end

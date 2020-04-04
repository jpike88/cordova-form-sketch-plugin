//
//  FPSketchScrollView.h
//  FormPigeon
//
//  Created by Joshua Pike on 14/02/2015.
//  Copyright (c) 2015 Joshua Pike. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECS189DrawingViewController;

@interface FPSketchScrollView : UIScrollView
@property (weak, nonatomic) ECS189DrawingViewController * sketchView;
@end

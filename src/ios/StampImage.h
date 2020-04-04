//
//  StampImage.h
//  FP
//
//  Created by Joshua Pike on 11/02/13.
//  Copyright (c) 2013 Joshua Pike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StampImage : UIImage
-(bool)pointContainedInShape:(CGPoint) point;

@property (strong, nonatomic) NSString* title;
@property CGPoint point;
@property CGPoint startPoint;
@property CGPoint endPoint;
@property NSInteger color;
@property bool isDashed;
@property int lineWidth;
@property int shape;
@property bool selected;
@end

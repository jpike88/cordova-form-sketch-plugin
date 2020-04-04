//
//  StampImage.m
//  FP
//
//  Created by Joshua Pike on 11/02/13.
//  Copyright (c) 2013 Joshua Pike. All rights reserved.
//

#import "StampImage.h"

@implementation StampImage



-(id)initWithContentsOfFile:(NSString *)path{
    
    self = [super initWithContentsOfFile:path];
    
    return self;
    
}



-(bool)pointContainedInShape:(CGPoint)point{
    
    return false;
    
}

@end

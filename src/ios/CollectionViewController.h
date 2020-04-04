//
//  CollectionViewController.h
//  FP
//
//  Created by Joshua Pike on 11/02/13.
//  Copyright (c) 2013 Joshua Pike. All rights reserved.
//
#import "FPSketch.h"

@class ECS189DrawingViewController;
@interface CollectionViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak ,nonatomic) ECS189DrawingViewController* fullScreen;
@property (weak, nonatomic) FPSketch * sketch;
@end

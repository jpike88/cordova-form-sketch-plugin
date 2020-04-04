//
//  CollectionViewController.m
//  FP
//
//  Created by Joshua Pike on 11/02/13.
//  Copyright (c) 2013 Joshua Pike. All rights reserved.
//

#import "CollectionViewController.h"
#import "ECS189DrawingViewController.h"
#import "StampImage.h"
@interface CollectionViewController ()

@end

@implementation CollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *cellNib = [UINib nibWithNibName:@"StampCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(145, 180)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    [self.collectionView setCollectionViewLayout:flowLayout];
}

-(void)orientationChanged:(NSNotification *)note{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
   // NSString *searchTerm = self.searches[section];

      return [[_sketch returnStampArray] count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    static NSString *cellIdentifier = @"cvCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView * cellImage = (UIImageView*)[cell viewWithTag:200];
  
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    
   StampImage* newImage = [[_sketch returnStampArray] objectAtIndex:indexPath.row];
    [titleLabel setText:[[_sketch returnTitleArray] objectAtIndex:indexPath.row]];
    titleLabel.numberOfLines = 0;
    [titleLabel sizeToFit];
    
    //NSLog(@"%f", cv.frame.size.width);
    [cellImage setImage:newImage];
   // [cell setBackgroundView:image];
    return cell;
}

- (void)collectionView:(UICollectionView *)colView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
}
- (void)collectionView:(UICollectionView *)colView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    StampImage* newImage = [[_sketch returnStampArray] objectAtIndex:indexPath.row];
    
    
    [_fullScreen stampMode:newImage];
    
    [_fullScreen dismissViewControllerAnimated:YES completion:nil];
    
}




@end

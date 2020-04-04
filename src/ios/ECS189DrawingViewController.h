//
//  ECS189ViewController.h
//  DrawingApp
//
//  Created by Lion User on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myShape.h"
#import "myUIPickerViewController.h"

#import "FPSketch.h"
#import "CollectionViewController.h"
#import "StampImage.h"
#import "SketchCompass.h"
#import "FPSketchScrollView.h"
#define SELECTMARGIN 10.0f
#define ALPHAOPAQUE 1.0f
#define ALPHATRANSPARENT 0.1f

@interface ECS189DrawingViewController : UIViewController <UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *stampWarning;
@property (strong, nonatomic) IBOutlet UIView *scrollTarget;

@property (weak, nonatomic) IBOutlet FPSketchScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *menuScrollView;
@property int degrees;
@property (strong, nonatomic) IBOutlet UIImageView *drawingPad;
@property (strong, nonatomic) IBOutlet UIImageView *grid;
@property (strong, nonatomic) IBOutlet UIImageView *placeholder;
@property int gridWidth;
@property (strong, nonatomic) NSString * labelForCompass;
@property BOOL stampActive;

@property (weak, nonatomic) IBOutlet UIButton *compassButton;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *saveExitButton;
@property (weak, nonatomic) IBOutlet UIButton *exitStampsButton;
@property (weak, nonatomic) IBOutlet UIButton *textSelect;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *stampsButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shapeView;

- (IBAction)compass:(id)sender;
@property (weak, nonatomic) FPSketch * sketchView;
@property (strong, nonatomic) NSMutableArray *collection;
@property (strong, nonatomic) NSMutableArray *collectionRedoQueue;
@property (weak, nonatomic) IBOutlet SketchCompass *compassCircle;
@property BOOL textActive;
@property BOOL compassActive;
@property StampImage *stampImage;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@property (strong, nonatomic) IBOutlet UIView *menuBar;
@property (strong, nonatomic) IBOutlet CollectionViewController *collectionView;

- (IBAction)startText:(id)sender;

@property (strong, nonatomic) UIImage * placeholderImage;
@property (weak, nonatomic) IBOutlet UILabel *compassLabel;
@property(strong, nonatomic) NSString *activeTextString;

@property (strong, nonatomic) UIPopoverController* stampPopoverController;
@property (strong, nonatomic) NSMutableArray *queue;


@property (strong, atomic) myShape *currentShape;
@property (weak, nonatomic) IBOutlet UILabel *textWarning;
- (IBAction)openStamps:(id)sender;
- (IBAction)exitStamps:(id)sender;
- (void)drawShapes:(myShape *)currentShape;
-(void)commitImage:(UIImage*)imageToCommit;
-(void)clearAll;
-(void)drawGrid;
-(CGPoint)nearestPoint:(CGPoint)point;
-(void)drawGridSubroutine:(CGPoint)begin :(CGPoint)end :(CGContextRef)context;
-(IBAction)exitFullScreen:(id)sender;
- (IBAction)redo:(id)sender;
-(void)undoRedoCheck;
-(void)stampMode:(StampImage *)stamp;
-(IBAction)undo:(id)sender;
@end

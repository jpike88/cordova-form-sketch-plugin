//
//  ECS189ViewController.m
//  DrawingApp
//
//  Created by Lion User on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cordova/CDV.h>
#import "ECS189DrawingViewController.h"
#import "CollectionViewController.h"
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#import <QuartzCore/QuartzCore.h>
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//#import "SketchViewController.h"
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface ECS189DrawingViewController() {
    bool skipDrawingCurrentShape;
    bool savedColorPickerHiddenState;
    bool currentSaved;
    NSInteger selectedIndex;
    NSInteger savedLineWidthValue;
    BOOL savedDashedState;
    CGPoint savedShapeStartpoint;
    CGPoint savedShapeEndpoint;
    
}

@property (weak, nonatomic) IBOutlet UISlider *lineWidthSlider;
@property (weak, nonatomic) IBOutlet UISwitch *dashedLineSelector;
@property (weak, nonatomic) IBOutlet myUIPickerViewController *colorPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shapeSelector;
@property (weak, nonatomic) IBOutlet UITableView *saveFileTableView;
@property (weak, nonatomic) IBOutlet UITextView *hintTextView;
@property (weak, nonatomic) IBOutlet UITextView *hintTextViewB;


@property NSInteger currentColor;
@property (strong, nonatomic) NSMutableArray *pickerArray;
@property (strong, nonatomic) NSMutableArray *fileSaveArray;
@property (strong, nonatomic) NSString *fileExtension;

- (IBAction)clearDrawingPad:(id)sender;
- (IBAction)colorPickerButton:(id)sender;
- (IBAction)saveButton:(id)sender;
- (IBAction)lineWidthMoved:(id)sender;
- (IBAction)isDashMoved:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)hintButtonPressed:(id)sender;
- (IBAction)doubleTappedInDrawingPad:(id)sender;
- (IBAction)loadButtonPressed:(id)sender;

- (UIColor *)colorForRow:(NSInteger)row;
- (void)drawShapes:(myShape *)currentShape;
- (void)drawShapesSubroutine:(myShape *)shapeToBeDrawn contextRef:(CGContextRef) context;
- (void)drawShapeSelector:(myShape *)shapeToBeDrawn selectorRect:(CGRect *) rect;
- (void)selectShapeOnScreen:(CGPoint) tapPoint;
- (void)clearSelectShapeOnScreen;
- (void)setCurrentShapeProperties;

// File operations
- (void)setupFileSaveArray;
- (NSString *)pathForDataFileWithFilename:(NSString *) filename;
- (void)saveDataToDiskWithFilename:(NSString *) filename;
- (void)deleteFileWithFilename:(NSString *) filename;
- (void)loadDataFromDiskWithFilename:(NSString *) filename;
- (NSString *)checkIfFileExists:(NSString *) filename;
@end

// Start implementation
@implementation ECS189DrawingViewController
@synthesize hintTextViewB = _hintTextViewB;
@synthesize hintTextView = _hintTextView;
@synthesize currentShape = _currentShape;   // Current shape the user is attempting to draw
@synthesize currentColor = _currentColor;   // The color selection

@synthesize drawingPad = _drawingPad;   // The drawing area
@synthesize shapeSelector = _shapeSelector; // The shape selection
@synthesize saveFileTableView = _saveFileTableView;
@synthesize lineWidthSlider = _lineWidthSlider; // Handle for the line width slider
@synthesize dashedLineSelector = _dashedLineSelector;   // Handle for the line dash picker

@synthesize colorPicker = _colorPicker; // Handle for the color picker, needs IMPROVEMENT
@synthesize pickerArray = _pickerArray; // Stores the colors
@synthesize collection = _collection;   // NSMutableArray that stores all the components for shape
@synthesize fileSaveArray = _fileSaveArray; // Lists the files saves
@synthesize fileExtension = _fileExtension;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)openStamps:(id)sender {
    
    
    
    //resize the popover view shown
    //in the current view to the view's size
    
    //create a popover controller
    
    [self presentViewController:_collectionView animated:YES completion:nil];
    [_exitStampsButton setHidden:NO];
    [_shapeSelector setHidden:YES];
    [_textSelect setHidden:YES];
    [_stampsButton setHidden:YES];
    [_clearButton setHidden:YES];
    [_saveExitButton setHidden:YES];
    
}

- (IBAction)exitStamps:(id)sender {
    
    [_stampWarning setHidden:YES];
    [_stampsButton setHidden:YES];
    _stampActive = NO;
    [_exitStampsButton setHidden:YES];
    [_shapeSelector setHidden:NO];
    [_textSelect setHidden:NO];
    [_stampsButton setHidden:NO];
    [_clearButton setHidden:NO];
    [_saveExitButton setHidden:NO];
    
}

-(void)commitImage:(UIImage *)imageToCommit{
    
    NSLog(@"image to commit is %@", [imageToCommit description]);
    //imageToCommit;
    //[_sketchView setSketchImage:imageToCommit];
    
}

-(void)orientationChanged:(NSNotification *)note{
    
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _scrollTarget;
}



#pragma mark - View lifecycle
- (void)viewDidLoad
{
    
    
    _grid = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _placeholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _drawingPad = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _scrollTarget = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [super viewDidLoad];
    _scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    
    if(IS_IPAD){
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 1.0;
        _scrollView.scrollEnabled = NO;
    } else {
        float finalScale = ((float)SCREEN_HEIGHT / 1024);
        _scrollView.minimumZoomScale = finalScale - 0.1;
        _scrollView.maximumZoomScale = 3.0;
        
        
        //_scrollView.contentSize = CGSizeMake(1024, 768);
        //CGFloat newContentOffsetX = (_scrollView.contentSize.width/2) - (_scrollView.bounds.size.width/2);
        //CGFloat newContentOffsetY = (_scrollView.contentSize.height/2) - (_scrollView.bounds.size.height/2);
        //_scrollView.contentOffset = CGPointMake(newContentOffsetX, newContentOffsetY);
        _scrollView.zoomScale = finalScale;
        
        
    }
    
    
    _scrollView.sketchView = self;
    
    [_scrollTarget addSubview:_grid];
    [_scrollTarget addSubview:_placeholder];
    [_scrollTarget addSubview:_drawingPad];
    [_scrollView addSubview:_scrollTarget];
    _scrollView.contentSize = CGSizeMake(1024, 768);
    [_menuBar setFrame:CGRectMake(0, 0, 1024, _menuBar.frame.size.height)];
    _menuBar.exclusiveTouch = YES;
    _menuScrollView.contentSize = CGSizeMake(1024, _menuScrollView.contentSize.height);
    [_menuScrollView addSubview:_menuBar];
    _compassCircle.exclusiveTouch = YES;
    _compassCircle.vc = self;
    _collectionView = [[CollectionViewController alloc] init];
    _collectionView.fullScreen = self;
    _collectionView.sketch = _sketchView;
    _currentShape = [[myShape alloc] init];
    _currentColor = 0;
    _fileSaveArray = [[NSMutableArray alloc] init];
    _gridWidth = 32;
    skipDrawingCurrentShape = FALSE;
    currentSaved = FALSE;
    selectedIndex = -1;
    savedShapeStartpoint = CGPointMake(0, 0);
    savedShapeEndpoint = CGPointMake(0, 0);
    _saveFileTableView.editing = YES;
    _saveFileTableView.allowsSelectionDuringEditing = YES;
    _saveFileTableView.hidden = YES;
    _fileExtension = @".DrawingPad";
    _stampActive = NO;
    [_stampWarning setHidden:YES];
    [_textWarning setHidden:YES];
    _pickerArray = [[NSMutableArray alloc] init];
    [_pickerArray addObject:@"Black"];
    [_pickerArray addObject:@"White"];
    [_pickerArray addObject:@"Red"];
    [_pickerArray addObject:@"Orange"];
    [_pickerArray addObject:@"Yellow"];
    [_pickerArray addObject:@"Green"];
    [_pickerArray addObject:@"Blue"];
    [_pickerArray addObject:@"Cyan"];
    [_pickerArray addObject:@"Violet"];
    _compassCircle.arrow = _arrow;
    [_stampsButton setHidden:NO];
    [_undoButton setHidden:YES];
    _stampWarning.layer.cornerRadius = 8;
    _stampWarning.layer.borderColor = _stampWarning.backgroundColor.CGColor;
    _stampWarning.layer.borderWidth = 3.0;
    [_redoButton setHidden:YES];
    if([[_sketchView returnStampArray] count] == 0){
        [_stampsButton setHidden:YES];
    }
    [self setupFileSaveArray];
    [_saveFileTableView reloadData];
    [_saveFileTableView setNeedsDisplay];
    
    [self drawGrid];
    
    UIImage *orangeButtonImage = [[UIImage imageNamed:@"orangeButton.png"]
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *orangeButtonImageHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"]
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    
    
    UIImage *blueButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blueButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"button.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    
    self.saveExitButton.layer.borderWidth = 0.0f;
    [self.saveExitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.saveExitButton setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.saveExitButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal];
    
    [self.saveExitButton setBackgroundImage:blueButtonImageHighlight forState:UIControlStateHighlighted];
    
    self.textSelect.layer.borderWidth = 0.0f;
    [self.textSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.textSelect setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.textSelect setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self.textSelect setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    self.stampsButton.layer.borderWidth = 0.0f;
    [self.stampsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.stampsButton setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.stampsButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self.stampsButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    self.undoButton.layer.borderWidth = 0.0f;
    [self.undoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.undoButton setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.undoButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
    
    [self.undoButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
    
    
    self.redoButton.layer.borderWidth = 0.0f;
    [self.redoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.redoButton setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.redoButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
    
    [self.redoButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
    
    self.compassButton.layer.borderWidth = 0.0f;
    [self.compassButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.compassButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.compassButton setTitle:self.labelForCompass forState:UIControlStateNormal];
    
    [self.compassButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_compassButton setTitle:@"Compass" forState:UIControlStateNormal];
    [self.compassButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [_compassButton setHighlighted:YES];
    [_compassButton setHidden:YES];
    
    
    self.clearButton.layer.borderWidth = 0.0f;
    [self.clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.clearButton setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.clearButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self.clearButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    self.exitStampsButton.layer.borderWidth = 0.0f;
    [self.exitStampsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.exitStampsButton setTitleColor:[UIColor colorWithRed:40 green:41 blue:65 alpha:1] forState:UIControlStateHighlighted];
    
    
    [self.exitStampsButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal];
    
    [self.exitStampsButton setBackgroundImage:blueButtonImageHighlight forState:UIControlStateHighlighted];
    
    [self undoRedoCheck];
    [_exitStampsButton setHidden:YES];
    [self.view bringSubviewToFront:_menuScrollView];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification object:app];
     */
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56)];
    
    int x = 20;
    
    NSMutableArray * buttonArray = [[NSMutableArray alloc] init];
    
    [buttonArray addObject:_shapeView];
    [buttonArray addObject:_textSelect];
    [buttonArray addObject:_stampsButton];
    [buttonArray addObject:_exitStampsButton];
    [buttonArray addObject:_undoButton];
    [buttonArray addObject:_redoButton];
    [buttonArray addObject:_clearButton];
    [buttonArray addObject:_saveExitButton];
    
    
    for (int i = 0; i < buttonArray.count; i++) {
        UIView *view = [buttonArray objectAtIndex:i];
        view.translatesAutoresizingMaskIntoConstraints = YES;
        view.frame = CGRectMake(x, 10, view.frame.size.width, view.frame.size.height);
        [view removeFromSuperview];
        [scrollView addSubview:view];
        
        x += view.frame.size.width + 20;
    }
    UIView* lastButton = (UIView*) [buttonArray lastObject];
    x = CGRectGetMaxX(lastButton.frame);
    
    if(IS_IPAD){
        scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height);
    } else {
        scrollView.contentSize = CGSizeMake(x + 600, scrollView.frame.size.height);
    }
    scrollView.backgroundColor = [UIColor darkGrayColor];
    scrollView.canCancelContentTouches = YES;
    [self.view addSubview:scrollView];
    
    
    scrollView.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width, self.view.frame.size.height), 56);
    
    
}



-(void)drawGrid{
    
    // Set the color in the current graphics context for future draw operations
    
    // Create our drawing path
    
    
    UIGraphicsBeginImageContext(_grid.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor] setStroke];
    
    // Draw a grid
    // first the vertical lines
    CGContextSetLineWidth(context, 2.0);
    CGFloat components[] = {0.0, 0.0, 1.0, 0.2};
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    
    
    for( int i = 0 ; i <= 1024 ; i=i+_gridWidth ) {
        
        [self drawGridSubroutine:CGPointMake(i, 0): CGPointMake(i, 768): context];
        
    }
    for( int i = 0 ; i <= 768 ; i=i+_gridWidth ) {
        
        
        [self drawGridSubroutine:CGPointMake(0,i) :CGPointMake(1024, i): context];
        
    }
    
    [[UIColor redColor] setStroke];
    
    // Draw a grid
    // first the vertical lines
    CGContextSetLineWidth(context, 2.0);
    CGFloat components2[] = {1.0, 0.0, 0.0, 0.2};
    CGColorSpaceRef colorspace2 = CGColorSpaceCreateDeviceRGB();
    CGColorRef color2 = CGColorCreate(colorspace2, components2);
    CGContextSetStrokeColorWithColor(context, color2);
    
    [self drawGridSubroutine:CGPointMake(1024/2, 0): CGPointMake(1024/2, 768): context];
    [self drawGridSubroutine:CGPointMake(0,768/2) :CGPointMake(1024, 768/2): context];
    
    
    _grid.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

-(void)drawGridSubroutine:(CGPoint)begin :(CGPoint)end :(CGContextRef)context{
    
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, begin.x, begin.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    
}

- (void)viewDidUnload
{
    
    [self setShapeSelector:nil];
    [self setDrawingPad:nil];
    [self setLineWidthSlider:nil];
    [self setDashedLineSelector:nil];
    [self setSaveFileTableView:nil];
    [self setHintTextView:nil];
    [self setHintTextViewB:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self undoRedoCheck];
    [self drawShapes:[[myShape alloc] init]];
    
    if(_compassActive){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.01f];
        
        
        [_arrow setTransform: CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(self.degrees))];
        [_arrow setHidden:NO];
        
        [UIView commitAnimations];
    } else {
        [_compassCircle setHidden:YES];
        [self.compassLabel setHidden:YES];
        [self performSelector:@selector(doUnHighlight:) withObject:_compassButton afterDelay:0];
        [_arrow setHidden:YES];
    }
    
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


-(void)applicationWillResignActive:(UIApplication *)application {
    // [self saveDataToDiskWithFilename:@""];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self){
        
        _compassActive = NO;
        
    }
    
    return self;
    
}

#pragma mark - drawing functions

- (void)drawShapes:(myShape *)currentShape {
    //NSLog(@"In drawShapes!");
    
    
    UIGraphicsBeginImageContext(_drawingPad.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw stamps first.
    
    
    
    NSMutableArray *stampsArray =[[NSMutableArray alloc] init];
    NSMutableArray *otherArray =[[NSMutableArray alloc] init];
    
    if(!_currentShape || currentShape){
        for(NSObject *i in _collection) {
            
            if([i isKindOfClass:[StampImage class]]){
                [stampsArray addObject:i];
            } else {
                [otherArray addObject:i];
            }
            
        }
        
        for(NSObject *i in stampsArray) {
            
            [self drawShapesExtended:i withContext:context];
            
        }
        
        for(NSObject *i in otherArray){
            
            [self drawShapesExtended:i withContext:context];
            
        }
    } else {
        
    }
    
    if(!skipDrawingCurrentShape && (selectedIndex == -1)) {
        [self drawShapesSubroutine:_currentShape contextRef:context];
    }
    
    _drawingPad.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)drawShapesExtended:(NSObject*)i withContext:(CGContextRef)context{
    
    if([i isKindOfClass:[myShape class]]){
        myShape *shape = (myShape*) i;
        [self drawShapesSubroutine:shape contextRef:context];
        if(shape.selected == true) {
            CGContextSetLineWidth(context, 1.0f);
            CGContextSetStrokeColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
            CGFloat num[] = {6.0, 6.0};
            CGContextSetLineDash(context, 0.0, num, 2);
            
            CGRect rectangle;
            [self drawShapeSelector:shape selectorRect: &rectangle];
            CGContextAddRect(context, rectangle);
            CGContextStrokePath(context);
        }
        
        //tapped = true;
    }
    
    
    if([i isKindOfClass:[StampImage class]]){
        
        StampImage * stamp = (StampImage*) i;
        CGPoint tempPoint = stamp.point;
        [stamp drawInRect:CGRectMake(tempPoint.x, tempPoint.y, _gridWidth, _gridWidth)];
        
        
    }
    
    if([i isKindOfClass:[UILabel class]]){
        
        UILabel * label = (UILabel*) i;
        CGPoint tempPoint = label.frame.origin;
        [label drawTextInRect:CGRectMake(tempPoint.x, tempPoint.y, 768, _gridWidth)];
        
    }
    
    if([i isKindOfClass:[UIImage class]] && ![i isKindOfClass:[StampImage class]]){
        
        UIImage *image = (UIImage *) i;
        [image drawInRect:CGRectMake(0, 0, 1024, 768)];
        
        
    }
    
    
}

- (void)drawShapesSubroutine:(myShape *)shapeToBeDrawn contextRef:(CGContextRef)context {
    CGContextSetLineWidth(context, shapeToBeDrawn.lineWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    // Setting the dashed parameter
    if(shapeToBeDrawn.isDashed == true){
        CGFloat num[] = {10.0f, 10.0f};
        CGContextSetLineDash(context, 0.0, num, 2);
    }
    else {
        CGContextSetLineDash(context, 0.0, NULL, 0);
    }
    
    
    if(shapeToBeDrawn.shape == 0) { //line
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, shapeToBeDrawn.startPoint.x, shapeToBeDrawn.startPoint.y);
        CGContextAddLineToPoint(context, shapeToBeDrawn.endPoint.x, shapeToBeDrawn.endPoint.y);
        
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    else if(shapeToBeDrawn.shape == 1) {    //Rectangle
        
        CGRect rectangle = CGRectMake(shapeToBeDrawn.startPoint.x,
                                      shapeToBeDrawn.startPoint.y,
                                      shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x,
                                      shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y);
        
        CGContextAddRect(context, rectangle);
        CGContextStrokePath(context);
    }
    else if(shapeToBeDrawn.shape == 2) {    //Circle
        float X = 0.5*(shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x);
        float Y = 0.5*(shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y);
        
        
        float radius = sqrtf(0.5*X*X + 0.5*Y*Y);
        
        float originX = shapeToBeDrawn.startPoint.x + 0.5*(shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x);
        float originY = shapeToBeDrawn.startPoint.y + 0.5*(shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y);
        
        CGContextAddArc(context, originX, originY, radius, 0, M_PI * 2.0, 1);
        CGContextStrokePath(context);
    }
}

-(void)drawShapeSelector:(myShape *)shapeToBeDrawn selectorRect:(CGRect *) rect {
    float x = 0.0, y = 0.0, width = 0.0, height = 0.0;
    
    if(shapeToBeDrawn.shape == 0 || shapeToBeDrawn.shape == 1) { //Line & rectangle
        if(shapeToBeDrawn.startPoint.x < shapeToBeDrawn.endPoint.x) {
            x = shapeToBeDrawn.startPoint.x - SELECTMARGIN;
            width = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x + 2*SELECTMARGIN;
        }
        else {
            x = shapeToBeDrawn.endPoint.x - SELECTMARGIN;
            width = shapeToBeDrawn.startPoint.x - shapeToBeDrawn.endPoint.x + 2*SELECTMARGIN;
        }
        
        if(shapeToBeDrawn.startPoint.y < shapeToBeDrawn.endPoint.y) {
            y = shapeToBeDrawn.startPoint.y - SELECTMARGIN;
            height = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y + 2*SELECTMARGIN;
        }
        else {
            y = shapeToBeDrawn.endPoint.y - SELECTMARGIN;
            height = shapeToBeDrawn.startPoint.y - shapeToBeDrawn.endPoint.y + 2*SELECTMARGIN;
        }
        
    }
    else if(shapeToBeDrawn.shape == 2) {    // Circle
        float r, dx, dy;
        dx = shapeToBeDrawn.endPoint.x - shapeToBeDrawn.startPoint.x;
        dy = shapeToBeDrawn.endPoint.y - shapeToBeDrawn.startPoint.y;
        r = sqrtf(dx*dx + dy*dy);   // Radius of our shape
        
        x = shapeToBeDrawn.startPoint.x - r - SELECTMARGIN;
        y = shapeToBeDrawn.startPoint.y - r - SELECTMARGIN;
        
        width = height = 2*(r+SELECTMARGIN);
    }
    else {
        //NSLog(@"drawShapeSelector, shouldn't be here!");
    }
    
    x -= shapeToBeDrawn.lineWidth/2.0f;
    y -= shapeToBeDrawn.lineWidth/2.0f;
    width += shapeToBeDrawn.lineWidth;
    height += shapeToBeDrawn.lineWidth;
    
    *rect = CGRectMake(x, y, width, height);
}

-(IBAction)exitFullScreen:(id)sender{
    
    
    
    NSData *imageData = UIImagePNGRepresentation(self.drawingPad.image);
    NSString *encodedString = [NSString stringWithFormat:@"data:image/png;base64,%@", [imageData base64Encoding]];
    
    [[_sketchView stampValues] removeAllObjects];
    [[_sketchView stampTitles] removeAllObjects];
    
    //_sketchView.displayImage.image = self.drawingPad.image;
    //[self commitImage:_sketchView.displayImage.image];
    [_sketchView finishWithImage:encodedString];
}



#pragma mark - File Saving
- (NSString *) pathForDataFileWithFilename:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/DrawingApp/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //NSLog(@"%@", [folder stringByAppendingPathComponent:[filename stringByAppendingString:_fileExtension]]);
    return [folder stringByAppendingPathComponent:[filename stringByAppendingString:_fileExtension]];
}

- (void) saveDataToDiskWithFilename:(NSString *)filename {
    NSString * path = [self pathForDataFileWithFilename:filename];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:_collection forKey:@"collection"];
    [archiver finishEncoding];
    
    if(![data writeToFile:path atomically:YES]) {
        //NSLog(@"Didn't work!");
    }
}

- (void) loadDataFromDiskWithFilename:(NSString *)filename {
    NSString * path = [self pathForDataFileWithFilename:filename];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSArray *temp = [unarchiver decodeObjectForKey:@"collection"];
        [_collection removeAllObjects];
        for(myShape *i in temp) {
            [_collection addObject:i];
        }
        [self drawShapes:nil ];
    }
}

- (void)deleteFileWithFilename:(NSString *) filename {
    NSString *path = [self pathForDataFileWithFilename:filename];
    //NSLog(@"%@",path);
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)setupFileSaveArray {
    NSArray *temp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self pathForDataFileWithFilename:nil]
                                                                        error:nil];
    [_fileSaveArray removeAllObjects];
    for(NSString *i in temp) {
        //NSLog(@"%@", [i stringByReplacingOccurrencesOfString:_fileExtension withString:@""]);
        if([i isEqualToString:_fileExtension] == YES) {
            continue;
        }
        [_fileSaveArray addObject:[i stringByReplacingOccurrencesOfString:_fileExtension withString:@""]];
    }
}

- (NSString *)checkIfFileExists:(NSString *) filename {
    for(NSString *i in _fileSaveArray) {
        if([i isEqualToString:filename]) {
            return [self checkIfFileExists:[filename stringByAppendingString:@"(1)"]];
        }
    }
    
    return filename;
}

-(CGPoint)nearestPoint:(CGPoint)point{
    
    int x, y = 0;
    // if closer to left snap
    
    if (point.x < (point.x - fmod(point.x, _gridWidth)) + (_gridWidth/2)){
        
        x = (point.x - fmod(point.x, _gridWidth));
        
    }
    
    // if closer to right snap
    
    if (point.x >= (point.x - fmod(point.x, _gridWidth)) + (_gridWidth/2)){
        
        x = (point.x - fmod(point.x, _gridWidth)) + _gridWidth;
        
    }
    
    // if closer to top snap
    
    if (point.y < (point.y - fmod(point.y, _gridWidth)) + (_gridWidth/2)){
        
        y = (point.y - fmod(point.y, _gridWidth));
        
    }
    
    // if closer to bottom snap
    
    if (point.y >= (point.y - fmod(point.y, _gridWidth)) + (_gridWidth/2)){
        
        y = (point.y - fmod(point.y, _gridWidth)) + _gridWidth;
        
    }
    
    CGPoint pointLOL = CGPointMake(x, y);
    
    return pointLOL;
    
    
}

#pragma mark - touch interface

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    //NSLog(@"In touchesBegan!");
    
    // Receiving the touch event
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_drawingPad];
    //NSLog(@"begin point x = %f, y = %f", tempPoint.x, tempPoint.y);
    if(_stampActive){
        tempPoint.x = tempPoint.x - fmod(tempPoint.x, _gridWidth);
        tempPoint.y = tempPoint.y - fmod(tempPoint.y, _gridWidth);
        UIGraphicsBeginImageContext(_drawingPad.frame.size);
        
        
        CGImageRef cgImage = [_stampImage CGImage];
        StampImage *dupImage = [[StampImage alloc] initWithCGImage:cgImage];
        
        dupImage.point = CGPointMake(tempPoint.x, tempPoint.y);
        
        [dupImage drawInRect:CGRectMake(tempPoint.x, tempPoint.y, _gridWidth, _gridWidth)];
        
        [_collection addObject:dupImage];
        _drawingPad.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self drawShapes:nil ];
        
        
    } else if(_textActive){
        UIGraphicsBeginImageContext(_drawingPad.frame.size);
        
        CGRect rect = CGRectMake(tempPoint.x, tempPoint.y - 20, 200, 44);
        UILabel *text = [[UILabel alloc] initWithFrame:rect];
        text.text = _activeTextString;
        [text sizeToFit];
        [_collection addObject:text];
        _drawingPad.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_textWarning setHidden:YES];
        [self drawShapes:nil ];
    }else {
        _currentShape = [[myShape alloc] init];
        _currentShape.startPoint = [self nearestPoint:tempPoint];
        if(!self.placeholderImage){
            self.placeholderImage = [self.drawingPad.image copy];
        }
        
        _placeholder.image = self.drawingPad.image;
        
        
        
        //NSInteger touchesBeganSelectedIndex = -1;   // Checking to see if the new point still selectes the right shape.
        
        // Code checking to see if we need to move an object
        /* for(myShape* i in [_collection reverseObjectEnumerator]) {
         if([i pointContainedInShape:tempPoint]) {
         touchesBeganSelectedIndex = [_collection indexOfObject:i];
         break;
         }
         }
         
         if((touchesBeganSelectedIndex == -1) || (touchesBeganSelectedIndex != selectedIndex)) {    // If the newly touched area isn't previously tapped shape, then don't move
         selectedIndex = -1;
         [self clearSelectShapeOnScreen];
         }
         else {  // Newly touched point is within the previously selected shape, store the original points.
         myShape *obj = [_collection objectAtIndex:selectedIndex];
         savedShapeStartpoint = obj.startPoint;
         savedShapeEndpoint = obj.endPoint;
         }
         */
    }
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!_textActive){
        //NSLog(@"In touchesMoved!");
        UITouch *touch = [touches anyObject];
        CGPoint tempPoint = [touch locationInView:_drawingPad];
        // NSLog(@"moving point x = %f, y = %f", tempPoint.x, tempPoint.y);
        
        // Setting properties
        if(!_stampActive){
            _currentShape.endPoint = [self nearestPoint:tempPoint];
            
            if(selectedIndex == -1){    // If we aren't dragging a shape
                [self setCurrentShapeProperties];
            }
            else {  // If we are dragging a shape
                float dx = _currentShape.endPoint.x - _currentShape.startPoint.x,
                dy = _currentShape.endPoint.y - _currentShape.startPoint.y;
                //NSLog(@"(%f,%f)", dx, dy);
                myShape *obj = [_collection objectAtIndex:selectedIndex];
                obj.startPoint = CGPointMake(savedShapeStartpoint.x + dx, savedShapeStartpoint.y + dy);
                obj.endPoint = CGPointMake(savedShapeEndpoint.x + dx, savedShapeEndpoint.y + dy);
            }
            
            
            
        } else {
            
            _colorPicker.hidden = YES;
        }
    }
    
    if(!_stampActive && !_textActive){
        [self drawShapes:_currentShape ];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"In touchesEnded!");
    
    // Receiving the touch event
    UITouch *touch = [touches anyObject];
    CGPoint tempPoint = [touch locationInView:_drawingPad];
    //NSLog(@"%f,%f",tempPoint.x,tempPoint.y);
    //NSLog(@"%@s",[_colorPicker pointInside:tempPoint withEvent:event] ? @"Yes": @"No");
    // NSLog(@"finish point x = %f, y = %f", tempPoint.x, tempPoint.y);
    if(!_stampActive && !_textActive){
        // Check to see if it's a tap
        
        if(CGPointEqualToPoint(tempPoint, _currentShape.startPoint) == NO) {    // Drag
            //NSLog(@"You dragged!");
            
            // Setting properties
            _currentShape.endPoint = [self nearestPoint:tempPoint];
            
            if(selectedIndex == -1){    // New shape object!
                [self setCurrentShapeProperties];
                [_collection addObject: [[myShape alloc] initCopy:_currentShape]];
            }
            else {  // Dragged an already made shape
                float dx = _currentShape.endPoint.x - _currentShape.startPoint.x,
                dy = _currentShape.endPoint.y - _currentShape.startPoint.y;
                //NSLog(@"(%f,%f)", dx, dy);
                myShape *obj = [_collection objectAtIndex:selectedIndex];
                obj.startPoint = CGPointMake(savedShapeStartpoint.x + dx, savedShapeStartpoint.y + dy);
                obj.endPoint = CGPointMake(savedShapeEndpoint.x + dx, savedShapeEndpoint.y + dy);
            }
            [self drawShapes:nil ];
        }
        else {  // Tap
            skipDrawingCurrentShape = TRUE;
            [self selectShapeOnScreen:(CGPoint) tempPoint];
            _saveFileTableView.hidden = TRUE;
            skipDrawingCurrentShape = FALSE;
        }
    } else {
        
    }
    _textActive = NO;
    _currentShape = nil;
    self.placeholder.image = nil
    ;
    [_collectionRedoQueue removeAllObjects];
    [self undoRedoCheck];
    [self drawShapes:nil ];
    
    
}

-(void)undoRedoCheck{
    
    //NSLog(@"undo %d items, redo %d items", _collection.count, _collectionRedoQueue.count);
    
    if([_collectionRedoQueue count] == 0){
        [_redoButton setHidden:YES];
        [_redoButton setEnabled:NO];
    } else {
        [_redoButton setHidden:NO];
        [_redoButton setEnabled:YES];
    }
    
    if(_collection.count == 0){
        [_undoButton setHidden:YES];
        [_undoButton setEnabled:NO];
    } else {
        [_undoButton setHidden:NO];
        [_undoButton setEnabled:YES];
    }
    
}

// Sets the current shape's properties
- (void)setCurrentShapeProperties {
    _currentShape.shape = [_shapeSelector selectedSegmentIndex];
    _currentShape.lineWidth = 4;
    _currentShape.isDashed = NO;
    _currentShape.color = _currentColor;
}

#pragma mark - Working...

- (void)selectShapeOnScreen:(CGPoint) tapPoint {
    //NSLog(@"You tapped!");
    
    bool hidden = TRUE;
    selectedIndex = -1;
    
    // Checks to see if the tapped point is in range of any shapes
    for(myShape* i in [_collection reverseObjectEnumerator]) {
        if([i pointContainedInShape:tapPoint]) {
            //NSLog(@"Selected!");
            i.selected = TRUE;  // Sets the shape's select parameter to TRUE
            _lineWidthSlider.value = i.lineWidth;   // Sets the line width slider to the shape's line width
            _dashedLineSelector.on = i.isDashed;    // Sets the dashed line selector to shape's dashed state
            [_colorPicker selectRow:i.color inComponent:0 animated:YES];    // Sets the color picker to the color of the selected shape
            hidden = FALSE; // Show the color picker
            selectedIndex = [_collection indexOfObject:i];  // Store the selected index for dragging :)
            break;
        }
    }
    
    [self drawShapes:nil ];
    _colorPicker.hidden = hidden;
}

- (void)clearSelectShapeOnScreen {
    for(myShape *i in _collection) {
        i.selected = FALSE;
    }
}

#pragma mark - Color picker

- (IBAction)colorPickerButton:(id)sender {
    //NSLog(@"Clicked colorPickerButton");
    
    _colorPicker.alpha = ALPHAOPAQUE;
    _colorPicker.hidden = !_colorPicker.hidden;
}

-(UIColor *)colorForRow:(NSInteger)row {
    switch (row) {
        case 0:
            return [UIColor blackColor];
        case 1:
            return [UIColor whiteColor];
        case 2:
            return [UIColor redColor];
        case 3:
            return [UIColor orangeColor];
        case 4:
            return [UIColor yellowColor];
        case 5:
            return [UIColor greenColor];
        case 6:
            return [UIColor blueColor];
        case 7:
            return [UIColor cyanColor];
        case 8:
            return [UIColor purpleColor];
        default:
            return [UIColor blackColor];
            break;
    }
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [_pickerArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_pickerArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSLog(@"Selected Color: %@. Index of selected color: %i", [_pickerArray objectAtIndex:row], row);
    _currentColor = row;
    if(selectedIndex >= 0) {
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        obj.color = _currentColor;
        [self drawShapes:nil ];
    }
    
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileSaveArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"fileSaveTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [_fileSaveArray objectAtIndex:row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Saved files";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteFileWithFilename:[_fileSaveArray objectAtIndex:indexPath.row]];
        [_fileSaveArray removeObjectAtIndex:indexPath.row];
        [_saveFileTableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Row %d selected", indexPath.row);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Load " stringByAppendingString:[_fileSaveArray objectAtIndex:indexPath.row]]
                                                    message:@"Your current drawing will be gone!"
                                                   delegate:self
                                          cancelButtonTitle:@"NOOO!"
                                          otherButtonTitles:@"YES PLZ!", nil];
    alert.tag = 2;
    [alert show];
}

-(void)clearAll{
    [_collection removeAllObjects];
    skipDrawingCurrentShape = TRUE;
    [self drawShapes:nil ];
    
    [_arrow setHidden:YES];
    [_compassCircle setHidden:YES];
    [self.compassLabel setHidden:YES];
    [_compassButton setHighlighted:NO];
    _compassActive = NO;
    skipDrawingCurrentShape = FALSE;
    
}

- (IBAction)undo:(id)sender{
    
    [_collectionRedoQueue addObject:[_collection lastObject]];
    [_collection removeLastObject];
    skipDrawingCurrentShape = TRUE;
    
    [self undoRedoCheck];
    [self drawShapes:nil ];
    skipDrawingCurrentShape = FALSE;
    
    
    
}

- (IBAction)redo:(id)sender {
    
    
    [_collection addObject:[_collectionRedoQueue lastObject]];
    [_collectionRedoQueue removeLastObject];
    
    [self undoRedoCheck];
    
    skipDrawingCurrentShape = TRUE;
    
    
    [self drawShapes:nil ];
    skipDrawingCurrentShape = FALSE;
    
    
    
}


#pragma mark - Alert

- (IBAction)clearDrawingPad:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear All"
                                                    message:@"Are you sure you want to clear everything?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"YES", nil];
    alert.tag = 0;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag ==0 && buttonIndex == 1) { // Clear
        //NSLog(@"0");
        [_collection removeAllObjects];
        skipDrawingCurrentShape = TRUE;
        [_collectionRedoQueue removeAllObjects];
        [self undoRedoCheck];
        [self drawShapes:nil ];
        skipDrawingCurrentShape = FALSE;
        
    }
    
    if(alertView.tag == 1 && buttonIndex == 1) {    // Save
        NSString *filename = [alertView textFieldAtIndex:0].text;
        //NSLog(@"1:%@", filename);
        
        if([filename isEqualToString:@""]) {
            return;
        }
        
        [self saveDataToDiskWithFilename:[self checkIfFileExists:filename]];
        [self setupFileSaveArray];
        [_saveFileTableView reloadData];
        [_saveFileTableView setNeedsDisplay];
    }
    
    if(alertView.tag == 2 && buttonIndex == 1) {
        NSString *filename = [alertView.title stringByReplacingOccurrencesOfString:@"Load " withString:@""];
        
        [self loadDataFromDiskWithFilename:filename];
        skipDrawingCurrentShape = TRUE;
        [self drawShapes:nil ];
        skipDrawingCurrentShape = FALSE;
    }
    
    if(alertView.tag == 3 && buttonIndex == 1) {
        
        UITextField *text = [alertView textFieldAtIndex:0];
        
        if([text.text isEqualToString:@""])
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Text field is empty." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        } else {
            _textActive = YES;
            _activeTextString = text.text;
            [_textWarning setHidden:NO];
        }
        
        
        
    }
    
}

#pragma mark - Buttons & Features

- (IBAction)saveButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save this awesomeness!"
                                                    message:@"Name?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

- (IBAction)lineWidthMoved:(id)sender {
    if(selectedIndex >= 0){
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        obj.lineWidth = _lineWidthSlider.value;
        [self drawShapes:nil ];
    }
}

- (IBAction)isDashMoved:(id)sender {
    if(selectedIndex >= 0){
        myShape *obj = [_collection objectAtIndex:selectedIndex];
        obj.isDashed = _dashedLineSelector.on;
        [self drawShapes:nil ];
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    if(selectedIndex >= 0) {
        [_collection removeObjectAtIndex:selectedIndex];
        [self drawShapes:nil ];
        selectedIndex = -1;
        _colorPicker.hidden = TRUE;
    }
}

- (IBAction)hintButtonPressed:(id)sender {
    _hintTextView.hidden = !_hintTextView.hidden;
    _hintTextViewB.hidden = !_hintTextViewB.hidden;
}

- (IBAction)doubleTappedInDrawingPad:(id)sender {
    //NSLog(@"Double Tapped! :D");
    
    if(_shapeSelector.hidden) { // Controls are currently hidden
        for(UIView *i in _drawingPad.subviews) {
            if(i == _colorPicker) {
                i.hidden = savedColorPickerHiddenState;
                continue;
            }
            if(i == _saveFileTableView) {
                continue;
            }
            i.hidden = FALSE;
        }
    }
    else { // Controls are currently being shown
        savedColorPickerHiddenState = _colorPicker.hidden;
        for(UIView *i in _drawingPad.subviews) {
            if(i == _saveFileTableView) {
                continue;
            }
            i.hidden = TRUE;
        }
    }
}

-(void)stampMode:(StampImage *)stamp{
    
    _stampActive = YES;
    _textActive = NO;
    _stampImage = stamp;
    [_stampsButton setHidden:NO];
    [_stampWarning setHidden:NO];
    
}

- (IBAction)loadButtonPressed:(id)sender {
    //currentSaved = FALSE;
    [self setupFileSaveArray];
    [_saveFileTableView reloadData];
    [_saveFileTableView setNeedsDisplay];
    _saveFileTableView.hidden = !_saveFileTableView.hidden;
}

- (IBAction)startText:(id)sender {
    _stampActive = NO;
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter the text:", @"new_list_dialog")
                                                          message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [myAlertView textFieldAtIndex:0];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    myAlertView.tag = 3;
    [myAlertView show];
    [textField becomeFirstResponder];
}


- (IBAction)compass:(id)sender {
    
    
    // check if on or off.
    
    
    if(!_compassActive){
        // not active.
        // show arrow and circle.
        [_arrow setHidden:NO];
        [_compassCircle setHidden:NO];
        [self.compassLabel setHidden:NO];
        [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
        _compassActive = YES;
    } else {
        
        [_arrow setHidden:YES];
        [_compassCircle setHidden:YES];
        [self.compassLabel setHidden:YES];
        [_compassButton setHighlighted:NO];
        _compassActive = NO;
        
    }
    
    
    
    
}


- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

- (void)doUnHighlight:(UIButton*)b {
    [b setHighlighted:NO];
}


@end

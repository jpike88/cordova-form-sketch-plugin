#import "FPSketch.h"
#import "ECS189DrawingViewController.h"

@implementation FPSketch


- (void)startSketch:(CDVInvokedUrlCommand*)command
{
    
    
    
    
    //
    


    _callbackId = [command callbackId];
    
    NSString* image = [[command arguments] objectAtIndex:0];
    
    
    ECS189DrawingViewController * fullScreen = [[ECS189DrawingViewController alloc] init];
    _fullScreen = fullScreen;
    fullScreen.sketchView = self;
    fullScreen.collection = [[NSMutableArray alloc] init];
    fullScreen.collectionRedoQueue = [[NSMutableArray alloc] init];
    if(image.length > 0) {
        NSURL *url = [NSURL URLWithString:image];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *ret = [UIImage imageWithData:imageData];
        
        

        
        
        [fullScreen.collection addObject:ret];
        [fullScreen undoRedoCheck];
        [fullScreen drawShapes:nil ];

    } else {

        
        
    }
    
    fullScreen.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self.viewController presentViewController:fullScreen animated:YES completion:nil];
    
    
    
    
    //
}

- (void)loadStamp:(CDVInvokedUrlCommand*)command{
    
    _callbackId = [command callbackId];
    
    if(!_stampValues){
        _stampValues = [[NSMutableArray alloc]init];
    }
    if(!_stampTitles){
        _stampTitles = [[NSMutableArray alloc]init];
    }
    
    NSString* stampValue = [[command arguments] objectAtIndex:0];
    
    NSURL *url = [NSURL URLWithString:stampValue];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *ret = [UIImage imageWithData:imageData];
    
    [_stampValues addObject:ret];
    
    NSString* stampTitle = [[command arguments] objectAtIndex:1];
    [_stampTitles addObject:stampTitle];

    
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];   // error callback expects string ATM
    
    [self.commandDelegate sendPluginResult:result callbackId:_callbackId];

    
}

-(void)finishWithImage:(NSString *)img{

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:img];   // error callback expects string ATM
    
    [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
    //[self success:_result callbackId:_callbackId];
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(NSArray*)returnStampArray{
    return _stampValues;
}

-(NSArray*)returnTitleArray{
    return _stampTitles;
}




@end

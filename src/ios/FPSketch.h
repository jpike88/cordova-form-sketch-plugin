#import <Cordova/CDV.h>
@class ECS189DrawingViewController;
@interface FPSketch : CDVPlugin

// help
- (void)initHelp:(CDVInvokedUrlCommand*)command;
- (void)configHelp:(CDVInvokedUrlCommand*)command;
- (void)showHelpTopics:(CDVInvokedUrlCommand*)command;
//- (void)showHelp:(CDVInvokedUrlCommand*)command;




// sketch
- (void) startSketch:(CDVInvokedUrlCommand*)command;
@property (strong, nonatomic) CDVPluginResult * result;
-(NSArray*) returnStampArray;
-(NSArray*) returnTitleArray;
@property (weak, nonatomic) ECS189DrawingViewController * fullScreen;
@property (strong, nonatomic) NSString  * callbackId ;
@property (strong, nonatomic) NSMutableArray * stampValues;
@property (strong, nonatomic) NSMutableArray * stampTitles;



-(void)finishWithImage:(NSString*)img;
-(void)close;

@end

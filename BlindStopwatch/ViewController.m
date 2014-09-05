

#import "ViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "RBVolumeButtons.h"

@interface ViewController () {
    int previousStepperValue;
}

@end

@implementation ViewController

@synthesize buttonStealer = _buttonStealer;



- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
    running=false;
    reset=true;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"timerGoal"] != nil) timerGoal=10.0;
    else timerGoal = [defaults floatForKey:@"timerGoal"];
    
    [self updateTimeDisplay:timerGoal];

    
    
    id progressDelegate = self;

   self.buttonStealer = [[RBVolumeButtons alloc] init];
   self.buttonStealer.upBlock = ^{
       
       [progressDelegate buttonPressed];
       
   };
   self.buttonStealer.downBlock = ^{
       [progressDelegate buttonPressed];
       
   };

    [self.buttonStealer startStealingVolumeButtonEvents];
    


    nPointsVisible=20;
    
    self.ArrayOfValues = [[NSMutableArray alloc] init];

    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //2) Create the full file path by appending the desired file name
    timeValuesFile = [documentsDirectory stringByAppendingPathComponent:@"timeData0.dat"];
    
    //Load the array
    self.ArrayOfValues = [[NSMutableArray alloc] initWithContentsOfFile: timeValuesFile];
    
    if(self.ArrayOfValues == nil)
    {
        //Array file didn't exist... create a new one
        self.ArrayOfValues = [[NSMutableArray alloc] init];
        for (int i = 0; i < nPointsVisible; i++) {
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
            [myDictionary setObject:[NSDate date] forKey:@"date"];

            [self.ArrayOfValues addObject:myDictionary];
        }
    }
    
    
    
    
    // This is commented out because the graph is created in the interface with this sample app. However, the code remains as an example for creating the graph using code.
     //BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 20,  self.view.bounds.size.width, 320)];
     //myGraph.delegate = self;
     //myGraph.dataSource = self;
     //[self.view addSubview:myGraph];
    //self.myGraph=myGraph;

    self.myGraph.colorTop =[UIColor clearColor];
    self.myGraph.colorBottom =[UIColor clearColor];
    self.myGraph.colorLine = [UIColor blackColor];
    self.myGraph.colorXaxisLabel = [UIColor blackColor];
    self.myGraph.colorYaxisLabel = [UIColor blackColor];
    //myGraph.widthLine = 3.0;
    self.myGraph.colorPoint=[UIColor blackColor];
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    //myGraph.enableBezierCurve = YES;
    //myGraph.enableTouchReport = YES;
    //myGraph.alwaysDisplayPopUpLabels = YES;
    self.myGraph.enablePopUpReport = YES;
    //myGraph.enableYAxisLabel = YES;
    self.myGraph.autoScaleYAxis = YES;
    //myGraph.alwaysDisplayDots = YES;
    //myGraph.enableReferenceAxisLines = YES;
    self.myGraph.animationGraphEntranceTime = 0.4;
    //myGraph.alphaTop=.2;

    
    self.myGraph.userInteractionEnabled=YES;
    self.myGraph.multipleTouchEnabled=YES;
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinch setDelegate:self];
    [self.myGraph addGestureRecognizer:pinch];
    

    
    instructionLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(10.0, 56.0, 320.0, 40.0) ];
    instructionLabel.textColor = [UIColor blackColor];
    instructionLabel.backgroundColor = [UIColor clearColor];
    instructionLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:(24.0)];
    [self.view addSubview:instructionLabel];
    instructionLabel.text = @"<Press volume button";
    instructionLabel.alpha=0;
    

}

//- (IBAction)addOrRemoveLineFromGraph:(id)sender {
//    if (self.graphObjectIncrement.value > previousStepperValue) {
//        // Add line
//        [self.ArrayOfValues addObject:[NSNumber numberWithInteger:(arc4random() % 10000)]];
//        [self.ArrayOfDates addObject:[NSString stringWithFormat:@"%i", (int)[[self.ArrayOfDates lastObject] integerValue]+1]];
//        [self.myGraph reloadGraph];
//    } else if (self.graphObjectIncrement.value < previousStepperValue) {
//        // Remove line
//        [self.ArrayOfValues removeObjectAtIndex:0];
//        [self.ArrayOfDates removeObjectAtIndex:0];
//        [self.myGraph reloadGraph];
//    }
//    
//    previousStepperValue = self.graphObjectIncrement.value;
//}



- (IBAction)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {

        nPointsVisible*=1.0/([gestureRecognizer scale]*[gestureRecognizer scale]);
        
        [gestureRecognizer setScale:1.0];
        
        if(nPointsVisible>=[self.ArrayOfValues count]-1){
         nPointsVisible=[self.ArrayOfValues count]-1;
            return;
        }
        else if(nPointsVisible<=5){
            nPointsVisible=5;
            return;
        }
        self.myGraph.animationGraphEntranceTime = 0.0;

        [self.myGraph reloadGraph];

    }
}

- (IBAction)valueChanged:(UIStepper *)sender {
    timerGoal=[sender value];
    
    [self updateTimeDisplay:timerGoal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:timerGoal forKey:@"timerGoal"];
    [defaults synchronize];

}



#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    //return (int)[self.ArrayOfValues count];
    return nPointsVisible;

}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {

    index=[self.ArrayOfValues count]-nPointsVisible+index;
    
    return ([[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"accuracy"] floatValue]*1000);
}



//- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph{
//    return -1000;
//    
//}
//- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph{
//    return 1000;
//}



#pragma mark - SimpleLineGraph Delegate
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @"ms";
}

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 3;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.ArrayOfValues count];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    return @"";

    
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MM.dd HH:mm"];
    
    //index=[self.ArrayOfValues count]-nPointsVisible+index;

    //NSString *stringFromDate = [formatter stringFromDate:[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"date"]];
    //return [stringFromDate stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    //return stringFromDate;
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    self.labelValues.text = [NSString stringWithFormat:@"%02f", [[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"accuracy"] floatValue]  ];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.labelValues.text = [NSString stringWithFormat:@"%f", [[self.myGraph calculatePointValueSum] floatValue]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    self.labelValues.text = [NSString stringWithFormat:@"%f", [[self.myGraph calculatePointValueSum] floatValue]];
}

-(void)saveValues{
    //2) Create the full file path by appending the desired file name

    [self.ArrayOfValues writeToFile:timeValuesFile atomically:YES];
}




-(void)buttonPressed{
    
    if(running==false && reset){
        running=true;
        reset=false;
        startTime=[NSDate timeIntervalSinceReferenceDate];
        startTime +=timerGoal;
        


        [self updateTime];
    }
    else if(running==true){
        running=false;

        

    }
    else
    {
        reset=true;
    
        //save to disk
        //append array
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
        [myDictionary setObject:[NSNumber numberWithFloat:elapsed] forKey:@"accuracy"];
        [myDictionary setObject:[NSDate date] forKey:@"date"];
        
        [self.ArrayOfValues addObject:myDictionary];
        
        //update graph
        self.myGraph.animationGraphEntranceTime = 0.4;
        [self.myGraph reloadGraph];
        [self saveValues];
        
        
        [self updateTimeDisplay:timerGoal];



    }
    
    
}

-(void)updateTimeDisplay: (NSTimeInterval) interval{

    NSTimeInterval absoluteTime=fabs(interval);
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: absoluteTime];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(interval>=0)    [df setDateFormat:@"mm:ss.SSS"];
    else[df setDateFormat:@"-mm:ss.SSS"];
    
    NSString* dateStrig = [df stringFromDate:aDate];
    [counterLabel setText:dateStrig];
}
-(void)updateTime
{
    if(running){
        [counterLabel setText:[NSString stringWithFormat:@"%02u:%02u.%03u",arc4random()%99, arc4random()%60, arc4random()%999]];
        [self performSelector:@selector(updateTime) withObject:self afterDelay:arc4random()%5*0.01];
    }
    else{
        NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
        elapsed = startTime - currentTime;

        [self updateTimeDisplay:elapsed];

    }

    
}

- (void)viewDidUnload
{
   self.buttonStealer = nil;
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
   // Return YES for supported orientations
  // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end

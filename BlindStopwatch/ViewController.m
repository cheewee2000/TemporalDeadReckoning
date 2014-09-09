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
    if([defaults objectForKey:@"timerGoal"] == nil) timerGoal=1.0;
    else timerGoal = [defaults floatForKey:@"timerGoal"];

    if([defaults objectForKey:@"levelProgress"] == nil) levelProgress=0;
    else levelProgress = [defaults floatForKey:@"levelProgress"];
    
    if([defaults objectForKey:@"maxTimerGoal"] == nil) maxTimerGoal=1;
    else maxTimerGoal = [defaults floatForKey:@"maxTimerGoal"];
    
    
    [self updateTimeDisplay:0];

    
    //blocks for buttons
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
    
    
    [self loadData:timerGoal];
    
    
    
    
    //graph
    
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
    self.myGraph.widthLine = 2.0;
    self.myGraph.colorPoint=[UIColor blackColor];
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.autoScaleYAxis = YES;

    self.myGraph.animationGraphEntranceTime = 0.4;
    //myGraph.alphaTop=.2;
    //myGraph.enableBezierCurve = YES;
    //myGraph.alwaysDisplayDots = YES;
    //myGraph.enableReferenceAxisLines = YES;
    //myGraph.enableYAxisLabel = YES;
    //myGraph.alwaysDisplayPopUpLabels = YES;

    
    
    self.myGraph.userInteractionEnabled=YES;
    self.myGraph.multipleTouchEnabled=YES;
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinch setDelegate:self];
    [self.myGraph addGestureRecognizer:pinch];
    
//    UISwipeGestureRecognizer *mSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    [mSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight)];
//    [[self view] addGestureRecognizer:mSwipeUpRecognizer];
//    
//    
    
//    instructionLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(10.0, 56.0, 320.0, 40.0) ];
//    instructionLabel.textColor = [UIColor blackColor];
//    instructionLabel.backgroundColor = [UIColor clearColor];
//    instructionLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:(24.0)];
//    [self.view addSubview:instructionLabel];
//    instructionLabel.text = @"<Press volume button";
//    instructionLabel.alpha=0;
    
    
    //stats
    
    UIFont * LF=[UIFont fontWithName:@"HelveticaNeue" size:32];
    UIFont * SMF=[UIFont fontWithName:@"HelveticaNeue" size:8];
    
    lastResults=[[UILabel alloc] initWithFrame:CGRectMake(0, 8, 50, 50)];
    lastResults.font = LF;
    lastResults.textColor =  [UIColor blackColor];
    [stats addSubview:lastResults];
    
    accuracy=[[UILabel alloc] initWithFrame:CGRectMake(stats.frame.size.width*.33, 8, 40, 50)];
    accuracy.font = LF;
    accuracy.textColor =  [UIColor blackColor];
    [stats addSubview:accuracy];
    
    precision=[[UILabel alloc] initWithFrame:CGRectMake(stats.frame.size.width*.66, 8, 50, 50)];
    precision.font = LF;
    precision.textColor =  [UIColor blackColor];
    precision.adjustsFontSizeToFitWidth=YES;
    [stats addSubview:precision];
    
    //UNITS
    UILabel* precisionUnit=[[UILabel alloc] initWithFrame:CGRectMake(precision.frame.origin.x+precision.frame.size.width, 0, 80, 50)];
    precisionUnit.text=@"ms";
    precisionUnit.font = SMF;
    [stats addSubview:precisionUnit];

    UILabel* accuracyUnit=[[UILabel alloc] initWithFrame:CGRectMake(accuracy.frame.origin.x+accuracy.frame.size.width, 0, 80, 50)];
    accuracyUnit.text=@"%";
    accuracyUnit.font = SMF;
    [stats addSubview:accuracyUnit];
    
    
    //LABELS
    float y=stats.frame.size.height-15;
    
    UILabel* lastResultLabel=[[UILabel alloc] initWithFrame:CGRectMake(lastResults.frame.origin.x, y, stats.frame.size.width*.33-12, 20)];
    lastResultLabel.text=@"LAST RESULTS";
    [lastResultLabel setTextAlignment:NSTextAlignmentRight];
    lastResultLabel.font = SMF;
    [stats addSubview:lastResultLabel];
    
    UILabel* accuracyLabel=[[UILabel alloc] initWithFrame:CGRectMake(accuracy.frame.origin.x, y, stats.frame.size.width*.33-12, 20)];
    accuracyLabel.text=@"ACCURACY";
    [accuracyLabel setTextAlignment:NSTextAlignmentRight];
    accuracyLabel.font = SMF;
    [stats addSubview:accuracyLabel];
    
    UILabel* precisionLabel=[[UILabel alloc] initWithFrame:CGRectMake(precision.frame.origin.x, y, stats.frame.size.width*.33-12, 20)];
    precisionLabel.text=@"PRECISION";
    [precisionLabel setTextAlignment:NSTextAlignmentRight];
    precisionLabel.font = SMF;
    [stats addSubview:precisionLabel];
    
    //FRAME
    //CGContextRef currentContext =UIGraphicsGetCurrentContext();
    //drawLine(currentContext, CGPointMake(stats.frame.origin.x,stats.frame.origin.y), CGPointMake(stats.frame.origin.x+10,stats.frame.origin.y),  [[UIColor blackColor] CGColor]);
    
    //Dots
    dots=[NSArray array];
    
    for (int i=0;i<10;i++){
        Dots *circleView = [[Dots alloc] initWithFrame:CGRectMake(8+(self.view.frame.size.width-8)/10.0*i,150,15,15)];
        circleView.alpha = 1;
        circleView.backgroundColor = [UIColor clearColor];
        [circleView setFill:NO];
        [circleView setClipsToBounds:NO];
        dots = [dots arrayByAddingObject:circleView];
        [self.view addSubview:dots[i]];
    }
    [self updateDots];

}

-(void)loadData:(float) timerGoal{
    //load values
    self.ArrayOfValues = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    timeValuesFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeData%i.dat",(int)timerGoal]];
    
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
}


-(void)saveValues{
    [self.ArrayOfValues writeToFile:timeValuesFile atomically:YES];
}

-(void) updateDots{
    for (int i=0;i<10;i++){
        if(i<levelProgress) [[dots objectAtIndex:i ] setFill:YES];
        else [[dots objectAtIndex:i] setFill:NO];
    }
}


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

//- (IBAction)swipe:(UISwipeGestureRecognizer *)recognizer {
//    
//    //CGPoint location = [recognizer locationInView:self.view];
//    
//    //[self drawImageForGestureRecognizer:recognizer atPoint:location];
//    
//    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
//        timerGoal=timerGoal*.5;
//    }
//    else {
//        timerGoal=timerGoal*2.0;
//    }
//    
//    if(timerGoal>maxTimerGoal)timerGoal=maxTimerGoal;
//    else if(timerGoal<1)timerGoal=1;
//    self.view.alpha = 0.0;
//    [self loadData:timerGoal];
//    
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        self.view.alpha = 1.0;
//    }];
//}




# pragma mark labels
-(void)updateTimeDisplay: (NSTimeInterval) interval{
    
    NSTimeInterval absoluteTime=fabs(interval);
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: absoluteTime];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    //if(interval>=0)    [df setDateFormat:@"mm:ss.SSS"];
    //else[df setDateFormat:@"-mm:ss.SSS"];
    
    [df setDateFormat:@"mm:ss.SSS"];
    NSString* counterString = [df stringFromDate:aDate];
    [counterLabel setText:counterString];
    
    
    //goal String
    NSTimeInterval goalInterval=fabs(timerGoal);
    NSDate* gDate = [NSDate dateWithTimeIntervalSince1970: goalInterval];
    NSDateFormatter* gf = [[NSDateFormatter alloc] init];
    [gf setDateFormat:@"/mm:ss.SSS"];
    NSString* goalString = [gf stringFromDate:gDate];
    [counterGoalLabel setText:goalString];
    

    //next goal String
    NSTimeInterval nextGoal=fabs(timerGoal*2.0);
    NSDate* nDate = [NSDate dateWithTimeIntervalSince1970: nextGoal];
    NSDateFormatter* ngf = [[NSDateFormatter alloc] init];
    [ngf setDateFormat:@"mm:ss.SSS"];
    NSString* nGoalString = [ngf stringFromDate:nDate];
    [nextLevelLabel setText:[NSString stringWithFormat:@"NEXT LEVEL:%@",nGoalString]];
    
    
}


-(void)updateTime{
    if(running){
        [counterLabel setText:[NSString stringWithFormat:@"%02u:%02u.%03u",arc4random()%99, arc4random()%60, arc4random()%999]];
        [self performSelector:@selector(updateTime) withObject:self afterDelay:arc4random()%5*0.01];
    }
    else{
        NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
        //elapsed = startTime - currentTime;
        elapsed = currentTime-startTime;
        [self updateTimeDisplay:elapsed];
    }
}


-(void)updateStats{
    lastResults.text=[NSString stringWithFormat:@"%02d",nPointsVisible];
    
    
    float accuracyP=100.0-fabs(([[self.myGraph calculatePointValueAverage] floatValue])/1000.0)/(float)timerGoal*100.0;
    
    accuracy.text = [NSString stringWithFormat:@"%02i", (int)accuracyP];

    
    float uncertainty=[[self.myGraph calculatePointValueMedian] floatValue]-[[self.myGraph calculateMinimumPointValue] floatValue]+[[self.myGraph calculateMaximumPointValue] floatValue]-[[self.myGraph calculatePointValueMedian] floatValue];

    precision.text=[NSString stringWithFormat:@"%d",(int)uncertainty];

    
}



//stepper button
- (IBAction)valueChanged:(UIStepper *)sender {
    timerGoal=[sender value];
    
    [self updateTimeDisplay:timerGoal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:timerGoal forKey:@"timerGoal"];
    [defaults synchronize];
    [self loadData:timerGoal];
    

}

//volume buttons
-(void)buttonPressed{
    
    if(running==false && reset){
        running=true;
        reset=false;
        startTime=[NSDate timeIntervalSinceReferenceDate];
        //startTime +=timerGoal;
        
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
        [myDictionary setObject:[NSNumber numberWithFloat:(elapsed-timerGoal)] forKey:@"accuracy"];
        [myDictionary setObject:[NSDate date] forKey:@"date"];
        
        [self.ArrayOfValues addObject:myDictionary];
        
        //update graph
        self.myGraph.animationGraphEntranceTime = 0.4;
        [self.myGraph reloadGraph];
        [self saveValues];
        
        float accuracyP=100.0-fabs(elapsed-timerGoal)/(float)timerGoal*100.0;
        if(accuracyP>=90)levelProgress++;
        else levelProgress=0;
        
        if(levelProgress>=2){
            levelProgress=0;
            //load next level
            timerGoal=timerGoal*2;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setFloat:timerGoal forKey:@"timerGoal"];
            [defaults setFloat:timerGoal forKey:@"maxTimerGoal"];
            [defaults synchronize];
            
            [self loadData:timerGoal];
        }
        
        [self updateDots];

        [self updateTimeDisplay:0];
    }
}


#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    //return (int)[self.ArrayOfValues count];
    return nPointsVisible;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    index=[self.ArrayOfValues count]-nPointsVisible+index; //show last nPoints
    return ([[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"accuracy"] floatValue]*1000);
}




//- (IBAction)displayStatistics:(id)sender {
//    [self performSegueWithIdentifier:@"showStats" sender:self];
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    [super prepareForSegue:segue sender:sender];
//    
//    if ([segue.identifier isEqualToString:@"showStats"]) {
//        StatsViewController *controller = segue.destinationViewController;
//        controller.standardDeviation = [NSString stringWithFormat:@"%.2f", [[self.myGraph calculateLineGraphStandardDeviation] floatValue]];
//        controller.average = [NSString stringWithFormat:@"%.2f", [[self.myGraph calculatePointValueAverage] floatValue]];
//        controller.median = [NSString stringWithFormat:@"%.2f", [[self.myGraph calculatePointValueMedian] floatValue]];
//        controller.mode = [NSString stringWithFormat:@"%.2f", [[self.myGraph calculatePointValueMode] floatValue]];
//        controller.minimum = [NSString stringWithFormat:@"%.2f", [[self.myGraph calculateMinimumPointValue] floatValue]];
//        controller.maximum = [NSString stringWithFormat:@"%.2f", [[self.myGraph calculateMaximumPointValue] floatValue]];
//        controller.snapshotImage = [self.myGraph graphSnapshotImage];
//    }
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
    [self updateStats];
}

//- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph{
//    return -100;
//}
//- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph{
//    return 100;
//}


#pragma mark - ViewController Delegate

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

void drawLine(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


@end
